////////////////////////////////////////////////////////////////////////////////
unit gjRand32; //gjRand32 Delphi implementation by Markus_13
interface {tested in Delphi7 to match JavaScript implementation:
function gjrand32(a, b, c, d) {
    return function(){
        a|=0; b|=0; c|=0; d|=0;
        a=a<<16|a>>>16; b=b+c|0;
        a=a+b|0; c=c^b; c=c<<11|c>>>21;
        b=b^a; a=a+c|0; b=c<<19|c>>>13;
        c=c+a|0; d=d+0x96a5|0; b=b+d|0;
        return (a>>>0)/4294967296;
    }
//}

//----------------FUNCTION-LIST:------------------------------------------------

procedure gjRandSeeds(const a,b,c,d:cardinal); //set all 4 seeds manually
procedure gjRandomize(const seed:int64); //same as below
procedure gjRandSeed(const seed:int64); //single seed init with better shufflin'
function gjRandC:cardinal; //output:0..4294967295
function gjRand:single; overload; //output:0.0..1.0
function gjRand(const min,max:integer):integer; overload; //output:min..max
function gjSar(const base:integer; shift:cardinal):cardinal; //JS >>>

////////////////////////////////////////////////////////////////////////////////
implementation//================================================================
const gjSarM0Dz:array[1..31]of cardinal=( //helper array for gjSar func
$80000000,$40000000,$20000000,$10000000,
$8000000,$4000000,$2000000,$1000000,
$800000,$400000,$200000,$100000,
$80000,$40000,$20000,$10000,
$8000,$4000,$2000,$1000,
$800,$400,$200,$100,
$80,64,32,16,8,4,2);
var gjRandSeedA,gjRandSeedB,gjRandSeedC,gjRandSeedD:cardinal; //seeds

procedure gjRandSeeds(const a,b,c,d:cardinal);
begin
  gjRandSeedA:=a;
  gjRandSeedB:=b;
  gjRandSeedC:=c;
  gjRandSeedD:=d;
end;

procedure gjRandSeed(const seed:int64);
var i,n:cardinal;//for better shufflin'
begin
  gjRandSeeds(cardinal($C0DEF00D),cardinal($BED00DAD-seed),
cardinal(seed),cardinal(gjRandSeedA xor gjRandSeedC));
  n:=gjRandC mod 8;
  if(seed>MaxInt-2)then gjRandSeedD:=cardinal(seed)
   else gjRandSeedD:=cardinal(0-integer(seed));
  for i:=0 to 13+n do n:=gjRandC; //extra calls to init better
  gjRandSeedA:=cardinal(gjRandSeedA-(n mod 37)+1); {might be turned off}
end;

procedure gjRandomize(const seed:int64);
begin
  gjRandSeed(seed);
end;

//Delphi implementation of JavaScript (Zero Fill) Unsigned Right Shift ">>>"
function gjSar(const base:integer; shift:cardinal):cardinal;
begin
  shift:=shift mod 32;
  asm
    mov eax,base
    mov ecx,shift
    sar eax,cl
    mov result,eax
  end;
  if(shift>0)then result:=result mod gjSarM0Dz[shift];
end;

function gjRandC:cardinal;
begin
  gjRandSeedA:=(gjRandSeedA shl 16)or word(gjSar(gjRandSeedA,16));
  gjRandSeedB:=(gjRandSeedB+gjRandSeedC)or 0;
  gjRandSeedA:=(gjRandSeedA+gjRandSeedB)or 0;
  gjRandSeedC:=(gjRandSeedC xor gjRandSeedB);
  gjRandSeedC:=(gjRandSeedC shl 11)or(gjSar(gjRandSeedC,21));
  gjRandSeedB:=(gjRandSeedB xor gjRandSeedA);
  gjRandSeedA:=(gjRandSeedA+gjRandSeedC)or 0;
  gjRandSeedB:=(gjRandSeedC shl 19)or(gjSar(gjRandSeedC,13));
  gjRandSeedC:=(gjRandSeedA+gjRandSeedC)or 0;
  gjRandSeedD:=(gjRandSeedD+$96a5)or 0;
  gjRandSeedB:=(gjRandSeedB+gjRandSeedD)or 0;
  result:=gjRandSeedA;
end;

function gjRand:single;
begin
  result:=gjRandC/4294967295;
end;

function Floor(const x:extended):integer;
begin
  result:=integer(trunc(x));
  if(frac(x)<0)then dec(result);
end;

function gjRand(const min,max:integer):integer;
begin
  result:=Floor(gjRand()*(max-min+1))+min;
end;

//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
initialization
  gjRandSeed(0);
end.
////////////////////////////////////////////////////////////////////////////////
