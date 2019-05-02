#guard BinaryConverter

define {
    int   = integer
    bool  = boolean
    void  = nothing
    float = real
    TAPI = TriggerAPI
    HP(u) = GetUnitState(u, UNIT_STATE_LIFE)
}


library BinaryConverter
	
	define BIN_BITLEN = 32
	
	int div(int num, int devidor)
	{
		real res = num / devidor
		return R2I(res)
	}
	
	int mod(int dividend, int divisor)
	{
		local integer modulus = dividend - (dividend / divisor) * divisor
		if (modulus < 0) then
			set modulus = modulus + divisor
		endif
		return modulus
	}
	

	struct BitArray
		int length = 0
		int array bits[BIN_BITLEN]
		void Set(int pos, int value)
		{
			if(pos >= BIN_BITLEN || pos < 0) then
				return
			endif
			
			if(value == 0) then
				bits[pos] = 0
			else
				bits[pos] = 1
			endif
		}
		int Get(int pos)
		{
			if(pos >= BIN_BITLEN || pos < 0) then
				DisplayTextToPlayer(Player(0), 0, 0, "BitArray error: Index out of range")
				return 0
			endif
			
			return bits[pos]
		}	
		
		void FlushToZero()
		{
			length = 0
			int i = 0
			loop
				exitwhen i >= BIN_BITLEN
				bits[i] = 0
				i++
			endloop
		}
		
		string ToString()
		{
			string res = ""
			int i = BIN_BITLEN - 1
			loop
				exitwhen i < BIN_BITLEN - length
				res = I2S(bits[i]) + res
				i--
			endloop
			
			return res
		}
		
		int ToInt()
		{
			int i = BIN_BITLEN - 1
			int res = 0
			loop
				exitwhen i < BIN_BITLEN - length
				//DisplayTextToPlayer(Player(0), 0, 0, I2S(BIN_BITLEN - i))
				res += bits[i] * R2I(Pow(2, BIN_BITLEN - i - 1))
				i--
			endloop
			return res
		}

		static method create takes integer number returns thistype
			thistype this = thistype.allocate()
                //set this.durability = PhaserMaxHp[id]
                //set this.slot_id = id
			this.FlushToZero()
			int pos = BIN_BITLEN - 1
			loop
				exitwhen number <= 0 || pos < 0
				this.bits[pos] = mod(number, 2)
				number = div(number, 2)
				this.length++
				pos--
			endloop
			
            return this
		endmethod
		
	endstruct

	int WriteVal(int src, int sections, int pos, int value)
	{
		if(sections != 2 && sections != 4 && sections != 8 && sections != 16 && sections != 32) then
			DisplayTextToPlayer(Player(0), 0, 0, "BitArray error: Sections must be 2, 4, 8, 16, 32")
			return 0
		endif
		
		int sectionLen = BIN_BITLEN / sections		
		BitArray valBits = BitArray.create(value)
		if(sectionLen < valBits.length) then
			DisplayTextToPlayer(Player(0), 0, 0, "BitArray error: Sections cannot fit value!")
			return 0
		endif
		BitArray sourceBits = BitArray.create(src)
		sourceBits.length = BIN_BITLEN
		
		//DisplayTextToPlayer(Player(0), 0, 0, sourceBits.ToString())
		
		int start = pos * sectionLen
		int end = (pos + 1) * sectionLen
		//DisplayTextToPlayer(Player(0), 0, 0, "[" + I2S(start) + ", " + I2S(end) + "]")
		int valPos = 0
		int srcPos = start
		loop
			exitwhen srcPos >= end
			if(valPos <= valBits.length) then
				sourceBits.bits[BIN_BITLEN - srcPos] = valBits.bits[BIN_BITLEN - valPos]
			else
				sourceBits.bits[BIN_BITLEN - srcPos] = 0
			endif
			srcPos++
			valPos++
		endloop
		//DisplayTextToPlayer(Player(0), 0, 0, sourceBits.ToString())
		return sourceBits.ToInt()
	}
	
	int ReadVal(int src, int sections, int pos)
	{
		if(sections != 2 && sections != 4 && sections != 8 && sections != 16 && sections != 32) then
			DisplayTextToPlayer(Player(0), 0, 0, "BitArray error: Sections must be 2, 4, 8, 16, 32")
			return 0
		endif
		
		int sectionLen = BIN_BITLEN / sections
		BitArray sourceBits = BitArray.create(src)
		sourceBits.length = BIN_BITLEN
				//DisplayTextToPlayer(Player(0), 0, 0, sourceBits.ToString())
		BitArray valBits = BitArray.create(0)
		valBits.length = sectionLen
		int start = (sections - pos - 1) * sectionLen
		int end = ((sections - pos - 1) + 1) * sectionLen
		//DisplayTextToPlayer(Player(0), 0, 0, "[" + I2S(start) + ", " + I2S(end) + "]")
		int valPos = BIN_BITLEN - (end - start)
		int srcPos = start
		loop
			exitwhen srcPos >= end
			valBits.bits[valPos] = sourceBits.bits[srcPos]
			//DisplayTextToPlayer(Player(0), 0, 0, "srcPos: " + I2S(srcPos) + ", sourceBits[srcPos]: " + I2S(sourceBits.bits[srcPos]))
			srcPos++
			valPos++
		endloop
		DisplayTextToPlayer(Player(0), 0, 0, valBits.ToString())
		return valBits.ToInt()
	}
	
endlibrary 