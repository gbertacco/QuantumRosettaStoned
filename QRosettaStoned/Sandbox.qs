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
