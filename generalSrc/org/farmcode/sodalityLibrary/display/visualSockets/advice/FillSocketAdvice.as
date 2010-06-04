package org.farmcode.sodalityLibrary.display.visualSockets.advice
{
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.display.visualSockets.adviceTypes.IFillSocketAdvice;
	import org.farmcode.sodalityLibrary.display.visualSockets.sockets.IDisplaySocket;

	public class FillSocketAdvice extends Advice implements IFillSocketAdvice
	{
		private var _displayPath: String;
		private var _dataProvider: *;
		private var _displaySocket: IDisplaySocket;
		
		public function FillSocketAdvice(displayPath: String=null, dataProvider: *=null){
			super();
			this.displayPath = displayPath;
			this.dataProvider = dataProvider;
		}
		
		[Property(toString="true", clonable="true")]
		public function get displayPath(): String
		{
			return this._displayPath;
		}
		public function set displayPath(value: String): void
		{
			this._displayPath = value;
		}
		
		[Property(toString="true", clonable="true")]
		public function get displaySocket():IDisplaySocket
		{
			return this._displaySocket;
		}
		public function set displaySocket(value: IDisplaySocket): void
		{
			this._displaySocket = value;
		}
		
		[Property(toString="true", clonable="true")]
		public function get dataProvider(): *
		{
			return this._dataProvider;
		}
		public function set dataProvider(value: *): void
		{
			this._dataProvider = value;
		}
	}
}