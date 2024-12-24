// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Avito {
    address public owner;

    mapping(address => uint) public payments;

    struct Item {
        string name;
        uint price;
        address owner;
    }

    Item[] public items;

    event ItemListed(uint indexed itemId, string name, uint price, address owner);
    event ItemPurchased(uint indexed itemId, address indexed buyer, uint price);
    event FundsWithdrawn(address indexed to, uint amount);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function listItem(string memory name, uint price) public onlyOwner {
        require(price > 0, "Price must be greater than 0");
        items.push(Item(name, price, owner));
        emit ItemListed(items.length - 1, name, price, owner);
    }

    function purchaseItem(uint itemId) public payable {
        require(itemId < items.length, "Item does not exist");
        Item storage item = items[itemId];
        require(msg.value == item.price, "Incorrect payment amount");
        require(item.owner != msg.sender, "Cannot buy your own item");

        payments[msg.sender] += msg.value;

        item.owner = msg.sender;

        emit ItemPurchased(itemId, msg.sender, item.price);
    }

    function withdrawAll() public onlyOwner {
        address payable _to = payable(owner);
        uint amount = address(this).balance;
        require(amount > 0, "No funds to withdraw");

        _to.transfer(amount);

        emit FundsWithdrawn(_to, amount);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function refund() public {
        uint payment = payments[msg.sender];
        require(payment > 0, "No funds to refund");
        payments[msg.sender] = 0;

        address payable _to = payable(msg.sender);
        _to.transfer(payment);
    }

    function getItem(uint itemId) public view returns (string memory, uint, address) {
        require(itemId < items.length, "Item does not exist");
        Item memory item = items[itemId];
        return (item.name, item.price, item.owner);
    }
}
