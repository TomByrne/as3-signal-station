package org.tbyrne.gateways.interpreters
{
	import org.tbyrne.data.core.StringData;
	
	
	public class StringDataInterpreter implements IDataInterpreter
	{
		public function StringDataInterpreter()
		{
		}
		
		public function incoming(data:*):*{
			return new StringData(data as String);
		}
		
		public function outgoing(data:*):*{
			return (data as StringData).value;
		}

	}
}