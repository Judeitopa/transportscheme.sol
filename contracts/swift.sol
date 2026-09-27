//SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

// Error Function_OnlyDriver () {
//     require (msg.sender == Driver, "Opps Only a driver can register here!");
// }

// Error Function_OnlyStudent() {
//     require (msg.sender == Student, "Opps Only a student can register here!");
// }

contract SwiftTransportSystem {
    // MODIFIERS
    // address private driversAddress;
    // address private studentsAddress;
    // modifier onlyDriver() {
    //      require (msg.sender == driversAddress, "Opps Only a driver can register here!");
    //      _;
    // }
    // modifier onlyStudent() {
    //     require (msg.sender == studentsAddress, "Opps Only a student can register here!" );
    //     _;
    // }
    // modifier onlyOwner() {
    //     require (msg.sender == owner, "This is out of reach for students and drivers");
    //     _;
    // }

    address payable private owner; //this represents the address of the owner of the company whom the total balance of the contract wil be paid to, he will be the one to settle the drivers.
    constructor(address payable _owner) {
        owner = _owner;
    }
    struct Student {
        string name;
        string matricNo;
        uint level;
        string roomNo;
        uint departureTime;
        string departureDay;
        string location;
        uint phoneNo;
        bool paid; //This is default to false. Indicates whether the student has paid or not
    }
    struct Driver {
        string name;
        uint age;
        uint driversLicenseNo;
        string plateNo;
        string vehicleType;
        uint phoneNo;
    }

    mapping(uint DriversId => Driver) public drivers; // collects and stores details of all drivers

    mapping(string matricNo => Student) public students; // collects and stores details of all students

    function registerAsADriver(
        uint _driversregId,
        string memory _name,
        uint _age,
        uint _driversLicenseNo,
        string memory _plateNo,
        string memory _vehicleType,
        uint _phoneNo
    ) public {
        drivers[_driversregId] = Driver(
            _name,
            _age,
            _driversLicenseNo,
            _plateNo,
            _vehicleType,
            _phoneNo
        );
    }

    function registerAsAStudent(
        string memory _name,
        string memory _matricNo,
        uint _level,
        string memory _roomNo,
        uint _departureTime,
        string memory _departureDay,
        string memory _location,
        uint _phoneNo
    ) public {
        students[_matricNo] = Student(
            _name,
            _matricNo,
            _level,
            _roomNo,
            _departureTime,
            _departureDay,
            _location,
            _phoneNo,
            false
        );
    }
    struct AvailableRides {
        string location;
        string vehicleType;
        string imageUrl;
        uint availableSeats;
        uint price;
    }
    mapping(uint => AvailableRides) private seeavailableRides; // collects and stores details of all available rides
    uint[] private keyToAvailableRides;

    function listRide(
        uint _driversId,
        string memory _location,
        string memory _imageUrl,
        string memory _vehicleType,
        uint _availableSeats,
        uint _price
    ) public {
        seeavailableRides[_driversId] = AvailableRides(
            _location,
            _vehicleType,
            _imageUrl,
            _availableSeats,
            _price
        );

        keyToAvailableRides.push(_driversId); //keep track of the keys used in the "seeavailableRides" mapping in the keyToAvailableRides array
    }

    function seeAllAvailableRides()
        public
        view
        returns (AvailableRides[] memory)
    {
        //displays all the contents of the "seeavailableRides" mapping at once
        // Create a memory array with a fixed size equal to the number of tracked keys
        AvailableRides[] memory allRides = new AvailableRides[](
            keyToAvailableRides.length
        );

        // Loop through the tracked keys and populate the memory array
        for (uint i = 0; i < keyToAvailableRides.length; i++) {
            uint currentKey = keyToAvailableRides[i];
            allRides[i] = seeavailableRides[currentKey];
        }
        return allRides;
    }

    string[] private matricNums; //keeps track of every student that clicks the "bookRide()"
    uint256 private totalBookings = 0; // total number of bookings on the site

    function bookRide(
        uint _driversId,
        string memory _matricNo
    ) public payable returns (string memory) {
        //to know if there's still space on the ride you want to book

        require(
            seeavailableRides[_driversId].availableSeats > 0,
            "This ride is fully-booked"
        );

        //To book a particular ride, you use the driversId and this will help create an error message if you're paying wrong fees for the right ride
        require(msg.value > 0, "Insufficient funds");
        require(
            msg.value == seeavailableRides[_driversId].price,
            "Pls ensure you entered the exact amount for the ride at the inputed ID"
        );
        seeavailableRides[_driversId].availableSeats--; //decreases the number of available seats on a vehicle
        totalBookings++; //increases the total number of bookings on the site

        //I want to use the student's _matricNo to get a list of all the students who have booked a ride including all their details from the struct
        matricNums.push(_matricNo);

        return
            string.concat(
                "You successfully booked a ride going to ",
                seeavailableRides[_driversId].location
            );
    }

    function getTotalBookingOnTransportSite()
        public
        view
        returns (uint, string[] memory)
    {
        return (totalBookings, matricNums);
    }

    function withdraw() public payable {
        require(
            msg.sender == owner,
            "Only the owner of the contract can withdraw funds"
        );

        uint totalBalanceOftheContract = address(this).balance;

        //send/transfer the money to the owner of the swiftRideTransportSystems contract/company using the call method
        (bool success, ) = owner.call{value: totalBalanceOftheContract}("");
        require(success, "transaction failed to transfer to owner");
    }
}
