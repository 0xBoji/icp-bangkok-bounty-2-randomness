import Random "mo:base/Random";
import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";

actor class Backend() {
    // Connect to IC's random number generator
    private let ic : actor { raw_rand : () -> async [Nat8] } = actor "aaaaa-aa";
    
    // Player's balance
    private var balance : Nat = 100; // Start with 100 tokens
    
    // Convert random bytes to number
    private func bytesToNat(bytes : [Nat8]) : Nat {
        var n = 0;
        for (b in bytes.vals()) {
            n := n * 256 + Nat8.toNat(b);
        };
        n;
    };

    // Get current balance
    public query func getBalance() : async Nat {
        balance;
    };

    // Flip a coin with a bet
    public shared func flipCoin(betAmount : Nat) : async Text {
        // Check if player has enough balance
        if (betAmount > balance) {
            return "Not enough balance!";
        };

        // Get random number from IC
        let randomBytes = await ic.raw_rand();
        let randomNum = bytesToNat(randomBytes);
        let result = randomNum % 2; // 0 = Heads, 1 = Tails
        
        // Update balance based on win/loss
        if (result == 0) { // Heads
            balance += betAmount;
            return "Heads (0)! You won " # Nat.toText(betAmount) # " tokens!";
        } else { // Tails
            balance -= betAmount;
            return "Tails (1)! You lost " # Nat.toText(betAmount) # " tokens!";
        };
    };
}