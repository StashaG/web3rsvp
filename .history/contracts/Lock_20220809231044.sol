// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Web3RSVP {
    struct CreateEvent {
        bytes32 eventId;
        string eventDataCID;
        address eventOwner;
        uint256 eventTimestamp;
        uint256 deposit;
        uint256 maxCapacity;
        address[] confirmedRSVPs;
        address[] claimedRSVPs;
        bool paidOut;
    }

    mapping(bytes32 => CreateEvent) public idToEvent;

    function createNewEvent(
        uint256 eventTimestamp,
        uint256 deposit,
        uint256 maxCapacity,
        string calldata eventDataCID
    ) external {
        //generate an eventID based on other things passed in to generate a hash
        bytes32 eventId = keccak256(
            abi.encodePacked(
                msg.sender,
                address(this),
                eventTimestamp,
                deposit,
                maxCapacity
            )
        );
        
address[] memory confirmedRSVPs;
address[] memory claimedRSVPs;


//this creates a new CreateEvent struct and adds it to the idToEvent mapping
        idToEvent[eventId] = CreateEvent(
            eventId,
            eventDataCID,
            msg.sender,
            eventTimestamp,
            deposit,
            maxCapacity,
            confirmedRSVPs,
            claimedRSVPs,
            false
        );
    }

        function createNewEvent(bytes32 eventId) external payable {
            //look up event from our mapping
            CreateEvent storage myEvent = idToEvent[eventId];

            //transfer deposit to our contract / require that they sent in enough ETH to cover
            require(msg.value == myEvent.deposit, "NOT ENOUGH");

            //require that the event hasn't already happened (<eventTimestamp)
            require(block.timestamp <= myEvent.eventTimestamp, "ALREADY HAPPENED");

            // make sure event is under max capacity
            require(
                myEvent.confirmedRSVPs.length < myEvent.maxCapacity,
                "This event has reached capacity"
            );

            //require that msg.sender isn't already in myEvent.confirmedRSVPs AKA hasn't already RSVP'd
            for (uint8 i = 0; i < myEvent.confirmedRSVPs.length; i++){
                require(myEvent.confirmedRSVPs[i] != msg.sender, "ALREADY CONFIRMED");
            }

            myEvent.confirmedRSVPs.push(payable(msg.sender));
        }

        function confirmAttendee(bytes32 eventId, address attendee) public {
            // look up event from our struct using the eventID
            CreateEvent storage myEvent = idToEvent [eventId];

            // require that msg.sender is the owner of the event - only the host shoulde be able to check people in
            require(msg.sender == myEvent.eventOwner, "NOT AUTHORIZED");

            // require that attendee trying to check in actually RSVP's
            address rsvpConfirm;

            for (uint8 i = 0; i < myEvent.confirmedRSVPs.length; i++) {
                if(myEvent.confirmedRSVPs[i] == attendee){
                    rsvpConfirm = myEvent.confirmedRSVPs[i];
                }
            }

            require(rsvpConfirm == attendee, "NO RSVP TO CONFIRM");

            // require that attendee is NOT already in the claimedRSVPs list AKA make sure they haven't already checked in
            for (uint8 i = 0; i < myEvent.claimedRSVPs.length; i++) {
                require(myEvent.claimedRSVPs[i] != attendee, "ALREADY CLAIMED");
            }



        }

    
}