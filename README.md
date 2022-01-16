# gjRand32
gjRand32 Delphi implementation

tested in Delphi7 to match JavaScript implementation:

function gjrand32(a, b, c, d) {
    return function(){
        a|=0; b|=0; c|=0; d|=0;
        a=a<<16|a>>>16; b=b+c|0;
        a=a+b|0; c=c^b; c=c<<11|c>>>21;
        b=b^a; a=a+c|0; b=c<<19|c>>>13;
        c=c+a|0; d=d+0x96a5|0; b=b+d|0;
        return (a>>>0)/4294967296;
    }
}
