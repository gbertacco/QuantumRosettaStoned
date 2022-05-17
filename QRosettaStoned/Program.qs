namespace Quantum.QRosettaStoned {

    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    


    @EntryPoint()
    operation HelloQ () : Unit {
        FindAliveCat(0.9999);
    }

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
}
