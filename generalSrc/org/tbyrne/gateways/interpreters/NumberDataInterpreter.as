package org.tbyrne.gateways.interpreters
{
	import org.tbyrne.data.core.NumberData;
	
	
	public class NumberDataInterpreter implements IDataInterpreter
	{
		public function NumberDataInterpreter()
		{
		}
		
		public function incoming(data:*):*{
			//arrives as a Number
			return new NumberData(data as Number);
		}
		
		public function outgoing(data:*):*{
			//leaves as a Number
			return (data as NumberData).value;
		}

	}
}