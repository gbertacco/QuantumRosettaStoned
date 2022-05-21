namespace Quantum.DeutschJozsa {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Intrinsic;

    //Oracolo per strategia 0
    operation ApplyZeroOracle(control: Qubit, target : Qubit): Unit{
    }

    //Oracolo per strategia 1
    operation ApplyOneOracle(control: Qubit, target : Qubit): Unit{
        X(target); //secondo il libro, ma il risultato non cambia
    }

    //Oracolo per strategia ID
     operation ApplyIdOracle(control: Qubit, target : Qubit): Unit{
        CNOT(control,target);
    }

    //Oracolo per strategia NOT
    operation ApplyNotOracle(control: Qubit, target : Qubit): Unit{
        X(control);
        CNOT(control,target);
        X(control);
    }

     //L'input è il' control, l'output da leggere' il target
    operation ApplyQuantumStrategy(inputValue : Bool,oracle : ((Qubit, Qubit) => Unit)) : Unit{
        use control = Qubit();
        use target = Qubit();
        if(inputValue){
            X(control);  //Parte da 0 se inputValue è false parte da 1 se true
        }
        oracle(control,target);
        mutable result = (MResetZ(target) == One);
        Message($"From {inputValue} To {result}");
        Reset(control);
    }

    operation CheckQuantumOraclesResult() : Unit{
        Message("ZERO");
        ApplyQuantumStrategy(false,ApplyZeroOracle);
        ApplyQuantumStrategy(true,ApplyZeroOracle);
        Message("----------------");
        Message("ONE");
        ApplyQuantumStrategy(false,ApplyOneOracle);
        ApplyQuantumStrategy(true,ApplyOneOracle);
        Message("----------------");
        Message("ID");
        ApplyQuantumStrategy(false,ApplyIdOracle);
        ApplyQuantumStrategy(true,ApplyIdOracle);
        Message("----------------");
        Message("NOT");
        ApplyQuantumStrategy(false,ApplyNotOracle);
        ApplyQuantumStrategy(true,ApplyNotOracle);
    }

    //Azione dell'algoritmo di Deutsch-Josza versione 1
    // Leggere la dimostrazione Deutsch-Jozsa-Proof.txt
    operation CheckIfOracleIsBalancedV1(oracle : ((Qubit, Qubit) => Unit)) : Bool {
        use control = Qubit();
        use target = Qubit(); //Chiede alla macchina di darci due qubit, entrambi in |0>
        H(control); 
        X(target);
        H(target);//Prepara lo stato |+->
        oracle(control,target);//Richiama l'oracolo
        H(target); //il target sappiamo che sta in |-> così torna a |1>
        X(target); // reset a |0> reset manuale diciamo, il control invece è rimasto a |+> o |-> 
        mutable result = (MResetX(control) == Zero);// Zero <+| e <0|....One <-| e <1|
        Message($"{result}");
        return result;
    }
    //Azione dell'algoritmo di Deutsch-Josza
    operation RunDeutschJozsaAlgorithm() : Unit{
        Fact(CheckIfOracleIsBalancedV1(ApplyZeroOracle),"Test failed for zero oracle");
        Fact(CheckIfOracleIsBalancedV1(ApplyOneOracle),"Test failed for one oracle");
        Fact(not CheckIfOracleIsBalancedV1(ApplyIdOracle),"Test failed for id oracle");
        Fact(not CheckIfOracleIsBalancedV1(ApplyNotOracle),"Test failed for not oracle");
    }

     //Scorporazione della fase di preparazione dello stato
     operation PrepareTargetState(qubit : Qubit ) : Unit is Adj{
         X(qubit);
         H(qubit);
	 }

      //Azione dell'algoritmo di Deutsch-Josza versione 2
    operation CheckIfOracleIsBalancedV2(oracle : ((Qubit, Qubit) => Unit)) : Bool {
        use control = Qubit();
        use target = Qubit(); 
        H(control); 
        PrepareTargetState(target);
        oracle(control,target);
        Adjoint PrepareTargetState(target);
        mutable result = (MResetX(control) == Zero);
        Message($"{result}");
        return result;
    }

      //Azione dell'algoritmo di Deutsch-Josza versione 3
    operation CheckIfOracleIsBalancedV3(oracle : ((Qubit, Qubit) => Unit)) : Bool {
        use control = Qubit();
        use target = Qubit(); 
        H(control); 
        within{
            PrepareTargetState(target);
		}apply{
            oracle(control,target);
        }
        mutable result = (MResetX(control) == Zero);
        Message($"{result}");
        return result;
    }
}