namespace Quantum.Cryptography{

    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;

    function getAliceRandomBitExample() : Result[] {
       mutable message = [Zero, One, One,Zero,One,Zero,One,One,Zero];
       return message;
    }
    //False means + true means x
    function getAliceBasisExample() : Bool[] {
       mutable message = [false, false, false,true,true,true,false,true,true];
       return message;
    }

        //False means + true means x
    function getBobBasisExample() : Bool[] {
       mutable message = [false, true, false,false,true,false,false,false,true];
       return message;
    }

     operation polarizationAliceSendAndBobMeasure(aliceRandomBit: Result[],aliceBasis : Bool[],bobBasis : Bool[], observer: Bool) : Result[] {     
        let m = Length(aliceBasis);
        use qubits = Qubit[m];
        alicePrepareQubit(aliceRandomBit,aliceBasis,qubits);
        let n = Length(qubits);
        mutable result = new Result[n];
        for (i in 0 .. (n-1)) {
            if(observer){
                Ignore(M(qubits[i]));
            }
            let basisElem = bobBasis[i];
            if(basisElem){
               set result w/= i <- MResetX(qubits[i]);       
            }
            else{
               set result w/= i <- MResetZ(qubits[i]);     
            }
        }
        return result;
    }

     operation bobMeasureQubit(qubits : Qubit[], aliceRandomBit: Result[],aliceBasis : Bool[],bobBasis : Bool[], observer: Bool) : Result[] {     
        let n = Length(qubits);
        mutable result = new Result[n];
        for (i in 0 .. (n-1)) {
            if(observer){
                Ignore(M(qubits[i]));
            }
            let basisElem = bobBasis[i];
            if(basisElem){
               set result w/= i <- MResetX(qubits[i]);       
            }
            else{
               set result w/= i <- MResetZ(qubits[i]);     
            }
        }
        return result;
    }



    operation alicePrepareQubit(aliceRandomBit: Result[],aliceBasis : Bool[], qubits :Qubit[]):Unit{
        let m = Length(aliceBasis);
        for (i in 0 .. (m-1)) {
            let basisElem = aliceBasis[i];
            let aliceRandomBitElem = aliceRandomBit[i];
            projectQubit(qubits[i],basisElem,aliceRandomBitElem);
        }
    }
    //TODO
    operation projectQubit(qubit: Qubit,basisElem : Bool,aliceRandomBitElem : Result):Unit{
        if(aliceRandomBitElem==One){
            X(qubit);
        }
        if(basisElem){
            H(qubit);
        }
    }
    function handShakeOnCommonBasis(aliceBasis : Bool[] , bobBasis : Bool[]) : Int[]{
        let n = Length(aliceBasis);
        mutable agreements = numbersOfAgreements(aliceBasis , bobBasis);
        mutable result = new Int[agreements];
        mutable resultIndex=0;
        for (i in 0 .. (n-1)) {
            let aliceelement = aliceBasis[i];
            let basisElem = bobBasis[i];
            mutable index = i;
            if(basisElem==aliceelement){
               set result w/= resultIndex <- index; 
               set resultIndex = resultIndex+1;
		   }
        }
        return result;
    }

      function numbersOfAgreements(aliceBasis : Bool[] , bobBasis : Bool[]) : Int{
        //TODO capire se si possono fare dynamic array
        let n = Length(aliceBasis);
        mutable result =0;
        for (i in 0 .. (n-1)) {
            let aliceelement = aliceBasis[i];
            let basisElem = bobBasis[i];
            if(basisElem==aliceelement){
              set result = result +1;  
            }
        }
        return result;
    }

    function compareSecretKeys(aliceRandomBit : Result[],bobMeasure : Result[], agreements : Int[]) : Unit{
         let n = Length(agreements);
         mutable result = new Result[2];
        for (i in 0 .. (n-1)) {
            let aliceelement = aliceRandomBit[agreements[i]];
            let bobelement = bobMeasure[agreements[i]];
            mutable observer = false;
            if(aliceelement==Zero and bobelement==One){
                set observer=true;
            }
            if(aliceelement==One and bobelement==Zero){
               set observer=true;
            }
            Fact( not observer, "Someone is watching you");
        }
    }

    operation runQDK(observer: Bool): Unit{
       mutable aliceRandomBit = getAliceRandomBitExample();
       mutable aliceBasis = getAliceBasisExample();
       mutable bobBasis = getBobBasisExample();
       use qubits = Qubit[Length(aliceBasis)];
       alicePrepareQubit(aliceRandomBit,aliceBasis, qubits);
       mutable measureResult = bobMeasureQubit(qubits,aliceRandomBit,aliceBasis,bobBasis,observer);
       mutable handShake = handShakeOnCommonBasis(aliceBasis,bobBasis);
       for(i in 0 .. (1000)){
        compareSecretKeys(aliceRandomBit,measureResult, handShake);
       }
    }

}








   