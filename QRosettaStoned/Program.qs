namespace Quantum.QRosettaStoned{
    open Quantum.DeutschJozsa;
    open Microsoft.Quantum.Intrinsic;


    @EntryPoint()
    operation Main () : Unit {
        //Quantum.CatDeadOrAlive.FindAliveCat(0.9999);

       // Quantum.DeutschJozsa.RunDeutschJozsaAlgorithm();
    }
}
namespace Quantum.Gates {
        open Microsoft.Quantum.Intrinsic;
        open Microsoft.Quantum.Measurement;

        //L'operatore X inverte |0> con |1>
        //La misura va fatta sull'asse Z
        operation testX() : Unit{
            use control = Qubit();
            X(control);
            mutable result1 = (MResetZ(control) == Zero);
            if(result1){
                Message("control |0> to |0>");
            }else{
                Message("control |0> to |1>");
            }
        }

        //Simile al primo ma con due qubit
        operation test2X() : Unit{
        use control = Qubit();
        use target = Qubit();
        X(target);
        mutable result1 = (MResetZ(control) == Zero);
        if(result1){
            Message("control |0> to |0>");
        }else{
            Message("control |0> to |1>");
        }
         mutable result2 = (MResetZ(target) == Zero);
        if(result2){
            Message("target |0> to |0>");
        }else{
            Message("target |0> to |1>");
        }
    }

    //Test operatore CNOT
    //leaves the control qubit unchanged and performs a Pauli-X gate on the target qubit 
    //when the control qubit is in state ∣1⟩;
    //Quindi lo |00> rimane |00>,|01> rimane |01>, |10> diventa |11>, , |11> diventa |10>, 
     operation testCNOT() : Unit{
        use control = Qubit();
        use target = Qubit();
        X(control); //Modifica/commenta questo per fare le prove
        X(target); //Modifica/commenta questo per fare le prove
        CNOT(control,target);
        mutable result1 = (MResetZ(control) == Zero);
        if(result1){
            Message("control |0>");
        }else{
            Message("control |1>");
        }
         mutable result2 = (MResetZ(target) == Zero);
        if(result2){
            Message("target |0>");
        }else{
            Message("target |1>");
        }
    }

     //Dimostrazione che la misura su X equivale ad una Z ma sulle basi |+> e |->
        operation testZ() : Unit{
            use control = Qubit();
            X(control); //scommenta questo per provare il caso |1>
            H(control);
            mutable result1 = (MResetX(control) == Zero);
            if(result1){
                Message("Zero");
            }else{
                Message("One");
            }
        }
}


namespace Quantum.CatDeadOrAlive {

    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    

    operation PrepareBiasedCat(aliveProbability : Double, qubit : Qubit) : Unit {
        let rotationAngle =2.0*ArcCos(Sqrt(1.0 - aliveProbability));
        Ry(rotationAngle,qubit);
	}

    //Funzione non usata, proietta il qubit, che nasce in |0> però promettiamo alla
    //macchina di restituirlo in |0>
    operation GetNextRandomBit() : Result{
        use qubit = Qubit();//Chiede alla macchina target uno o più qubit
        H(qubit);//Operazione di Hadamard per prepararlo all'osservazione'
        return M(qubit); // Operazione di osservazione M, può restituire One o Zero
    }

    //La funzione molto simile alla precedente richiama una funzione statePreparation
    //che da un Qubit restituisce una Unit (freccia spessa =>)
    //Unit è la tupla vuota
    operation GetNextRandomBitReset(statePreparation : (Qubit => Unit )) : Result{
        use qubit = Qubit(); // Chiede un nuovo qubit
        statePreparation(qubit); //implementazione generica vedi GetNextRandomBit
        return MResetZ(qubit);
    }

    //Funzione da eseguire
    operation FindAliveCat(aliveProbability : Double) : Unit {
        mutable nRounds =0 ;
        mutable done = false;
        let prep = PrepareBiasedCat(aliveProbability, _);
        //Inizio flusso RUS repeat-until-success
        repeat {
            set nRounds +=1;
            set done = (GetNextRandomBitReset(prep)==Zero);
		}
        until done;
        //Fine flusso RUS
        Message($"It took {nRounds} observations to find cat alive");
    }

}

namespace Quantum.DeutschJozsa {
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Intrinsic;

    operation ApplyZeroOracle(control: Qubit, target : Qubit): Unit{
    }
    operation ApplyOneOracle(control: Qubit, target : Qubit): Unit{
        X(target); //secondo il libro, ma il risultato non cambia
    }
     operation ApplyIdOracle(control: Qubit, target : Qubit): Unit{
        CNOT(control,target);
        //Può tornare utile 
        //|++> = CNOT|++>
        //|--> = CNOT|+->
        //|-+> = CNOT|-+>
        //|+-> = CNOT|-->
    }
    operation ApplyNotOracle(control: Qubit, target : Qubit): Unit{
        X(control);
        CNOT(control,target);
        X(control);
    }
    operation CheckIfOracleIsBalanced(oracle : ((Qubit, Qubit) => Unit)) : Bool {
        use control = Qubit();
        use target = Qubit(); //Chiede alla macchina di darci due qubit, entrambi in |0>
        H(control); 
        X(target);
        H(target);//Prepara lo stato |+->
        oracle(control,target);//Richiama l'oracolo
        H(target); //il target sappiamo che sta in |-> così torna a |1> DUBBIO
        X(target); // reset a |0> reset manuale diciamo, il control invece è rimasto a |+> o |-> 
        mutable result = (MResetX(control) == Zero);// Zero <+| e <0|....One <-| e <1|
        Message($"{result}");
        return result;
    }
    operation RunDeutschJozsaAlgorithm() : Unit{
        Fact(CheckIfOracleIsBalanced(ApplyZeroOracle),"Test failed for zero oracle");
        Fact(CheckIfOracleIsBalanced(ApplyOneOracle),"Test failed for one oracle");
        Fact(not CheckIfOracleIsBalanced(ApplyIdOracle),"Test failed for id oracle");
        Fact(not CheckIfOracleIsBalanced(ApplyNotOracle),"Test failed for not oracle");
    }
}



   //Unit	Represents a singleton type whose only value is ().
    //Int	Represents a 64-bit signed integer. Values range from -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807.
    //BigInt	Represents signed integer values of any size.
    //Double	Represents a double-precision 64-bit floating-point number. Values range from -1.79769313486232e308 to 1.79769313486232e308 as well as NaN (not a number).
    //Bool	Represents Boolean values. Possible values are true or false.
    //String	Represents text as values that consist of a sequence of UTF-16 code units.
    //Qubit	Represents an opaque identifier by which virtual quantum memory can be addressed. Values of type Qubit are instantiated via allocation.
    //Result	Represents the result of a projective measurement onto the eigenspaces of a quantum operator with eigenvalues ±1. Possible values are Zero or One.
    //Pauli	Represents a single-qubit Pauli matrix. Possible values are PauliI, PauliX, PauliY, or PauliZ.
    //Range	Represents an ordered sequence of equally spaced Int values. Values may represent sequences in ascending or descending order.
    //Array	Represents values that each contain a sequence of values of the same type.
    //Tuple	Represents values that each contain a fixed number of items of different types. Tuples containing a single element are equivalent to the element they contain.
    //User defined type	Represents a user defined type consisting of named and anonymous items of different types. Values are instantiated by invoking the constructor.
    //Operation	Represents a non-deterministic callable that takes one (possibly tuple-valued) input argument returns one (possibly tuple-valued) output. Calls to operation values may have side effects and the output may vary for each call even when invoked with the same argument.
    //Function	Represents a deterministic callable that takes one (possibly tuple-valued) input argument returns one (possibly tuple-valued) output. Calls to function values do not have side effects and the output is will always be the same given the same input.
