namespace Quantum.QRosettaStoned{
    open Quantum.Cryptography;
    open Quantum.DeutschJozsa;
    open Microsoft.Quantum.Intrinsic;


    @EntryPoint()
    operation Main () : Unit {
        //Quantum.CatDeadOrAlive.FindAliveCat(0.9999);
       // Quantum.DeutschJozsa.RunDeutschJozsaAlgorithm();
       runQDK(true);
    }
}








   