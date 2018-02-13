//TO BE TESTED
pragma solidity ^0.4.0;

contract MultiSigWallet {
    
    /*
    Constants
    */
    uint constant MAX_OWNERS = 10;
    
    /*
    storage
    */
    address[] public owners;

    mapping(address => bool) public isOwner;
    
    mapping (uint => Transaction) private _transactions;

    uint private _transactionIndex;
    
    uint[] private _pendingTransactions;
    
    uint private required;
    
    /*
    Modifiers
    */
    
    modifier onlyWallet() {
        require(msg.sender == address(this));
        _;
    }
    
    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }
    
    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }
    
    modifier addressExists(address _address) {
        require(_address != 0);
        _;
    }
    
    modifier validNumOwners(uint ownerCount, uint _required) {
        require(ownerCount <= MAX_OWNERS
        && _required <= ownerCount
        && _required != 0
        && ownerCount != 0);
        _;
    }
    
    /*
    Events
    */
    event DepositFunds(address from, uint amount);
    event TransactionCreated(address from, address to, uint amount, uint transactionID);
    event TransactionCompleted(address from, address to, uint amount, uint transactionID);
    event TransactionDeleted(uint transactionID, address owner);
    event TransactionSigned(address by, uint transactionID);
    event OwnerAdded(address owner);
    event OwnerRemoved(address owner);
    event RequirementChanged(uint required);
    
    struct Transaction {
        address from;
        address to;
        uint amount;
        uint8 signatureCount;
        mapping (address => uint8) signatures;
    }
    
    //initialize wallet with owners and required number of approvals for transactions
    function MultiSigWallet(address[] _owners, uint _required) public validNumOwners(_owners.length, _required) {
        for (uint i=0; i<_owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != 0);
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
        
    }
    
    function addOwner(address owner) onlyWallet ownerDoesNotExist(owner) addressExists(owner) validNumOwners(owners.length + 1, required) public {
            isOwner[owner] = true;
            owners.push(owner);
            OwnerAdded(owner);
    }
    
    function removeOwner(address owner) onlyWallet ownerExists(owner) public {
        isOwner[owner] = false;
        for (uint i=0; i<owners.length - 1; i++)
        if (owners[i] == owner) {
            owners[i] = owners[owners.length - 1];
            break;
        }
        owners.length -= 1;
        if (required > owners.length)
        changeRequirement(owners.length);
        OwnerRemoved(owner);
    }
    
    //change required number of approvals for transaction
    function changeRequirement(uint _required) public onlyWallet validNumOwners(owners.length, _required) {
        required = _required;
        RequirementChanged(_required);
    }
    
    function () public payable {
        if (msg.value > 0)
        DepositFunds(msg.sender, msg.value);
    }
    
    function withdraw(uint amount) ownerExists(msg.sender) public {
        transferTo(msg.sender, amount);
    }
    
    //Create transaction and log ID
    function transferTo(address to, uint amount) ownerExists(msg.sender) public {
        require(address(this).balance >= amount);
        uint transactionID = _transactionIndex++;
        Transaction memory transaction;
        transaction.from = msg.sender;
        transaction.to = to;
        transaction.amount = amount;
        transaction.signatureCount = 0;
        
        _transactions[transactionID] = transaction;
        _pendingTransactions.push(transactionID);
        
        TransactionCreated(msg.sender, to, amount, transactionID);
        
    }
    
    function getPendingTransactions() view ownerExists(msg.sender) public returns (uint[]) {
        return _pendingTransactions;
    }
    
    //sign, update number of signs, if requirements ment complete transaction and update storage.
    function signTransaction(uint transactionID) ownerExists(msg.sender) public {
        Transaction storage transaction = _transactions[transactionID];
        
        //trans must exist
        require(0x0 != transaction.from);
        
        //creator cantt sign
        require(msg.sender != transaction.from);
        
        //not signed multiple times by same validOwner - must check
        require(transaction.signatures[msg.sender] == 0);
        
        transaction.signatures[msg.sender] =1;
        transaction.signatureCount++;
        
        TransactionSigned(msg.sender, transactionID);
        
        if (transaction.signatureCount >= required) {
            require(address(this).balance >= transaction.amount);
            transaction.to.transfer(transaction.amount);
            TransactionCompleted(transaction.from, transaction.to, transaction.amount, transactionID);
            deleteTransaction(transactionID);
        }
    }
    
    //remove transaction and remove from storage, log activity
    function deleteTransaction(uint transactionID) ownerExists(msg.sender) public {
        uint8 replace = 0;
        for(uint i = 0; i < _pendingTransactions.length; i++) {
            if (1 == replace) {
                _pendingTransactions[i-1] = _pendingTransactions[i];
            }
            else if (transactionID == _pendingTransactions[i]) {
                replace = 1;
            }
        }
        delete _pendingTransactions[_pendingTransactions.length -1];
        _pendingTransactions.length--;
        delete _transactions[transactionID];
        TransactionDeleted(transactionID, msg.sender);
    }
    
    function walletBalance() constant public returns (uint) {
        return address(this).balance;
    }
}
