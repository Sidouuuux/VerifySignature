// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title VerifySignature
/// @notice A contract for verifying signatures using the Ethereum Signed Message scheme
contract VerifySignature {
    /// @notice Verifies the validity of a signature
    /// @param _signer The expected signer address
    /// @param _message The message that was signed
    /// @param _signature The signature to be verified
    /// @return A boolean indicating whether the signature is valid
    function verify(
        address _signer,
        string memory _message,
        bytes memory _signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, _signature) == _signer;
    }

    /// @notice Calculates the hash of a message
    /// @param _message The message to be hashed
    /// @return The hash of the message
    function getMessageHash(string memory _message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    /// @notice Calculates the Ethereum Signed Message hash of a message hash
    /// @param _messageHash The hash of the message
    /// @return The Ethereum Signed Message hash of the message hash
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
        );
    }

    /// @notice Recovers the signer address from a signed message hash and signature
    /// @param _ethSignedMessageHash The Ethereum Signed Message hash
    /// @param _signature The signature
    /// @return The address of the signer
    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    /// @notice Splits a signature into its components
    /// @param sig The signature to be split
    /// @return r The `r` component of the signature
    /// @return s The `s` component of the signature
    /// @return v The `v` component of the signature
    function splitSignature(bytes memory sig)
        public
        pure
        returns (bytes32 r, bytes32 s, uint8 v)
    {
        // Why 65?
        // bytes32 r variable is 32 length
        // bytes32 s variable is 32 length
        // uint8 v variable is 1 length
        // 32 + 32 + 1 = 65
        require(sig.length == 65, "invalid signature length");

        // sig is a dynamic variable so the length is dynamic
        // the length of the variable is stored in the first 32 bytes
        // sig is a pointer variable to signature
        assembly {
            // mload loads 32 bytes from the pointer we give
            // but we have to skip the first 32 bytes which are storing the length and not the data
            // we use the add() command to do so
            // add() takes two parameters: the address to begin at and how many bytes to move
            // here we want to begin at the address of the signature variable which is sig
            // and skip the bytes storing the data which are the first 32 bytes
            r := mload(add(sig, 32))
            // we skip 32 bytes to skip the length and 32 bytes to skip the r data
            // 32 + 32 = 64
            s := mload(add(sig, 64))
            // we skip 32 bytes to skip the length,
            // 32 bytes to skip the r data
            // and another 32 bytes to skip the s data
            // 32 + 32 + 32 = 96
            v := byte(0, mload(add(sig, 96)))
        }
        // returns is not needed since the variables we want to return are declared in the return statement
    }
}
