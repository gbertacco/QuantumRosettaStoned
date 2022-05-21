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