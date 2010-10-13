package org.tbyrne.actLibrary.display.visualSockets.acts
{
	import org.tbyrne.actLibrary.display.visualSockets.actTypes.IFillSocketAct;
	import org.tbyrne.actLibrary.display.visualSockets.sockets.IDisplaySocket;
	import org.tbyrne.acting.acts.UniversalAct;

	public class FillSocketAct extends UniversalAct implements IFillSocketAct
	{
		private var _displayPath: String;
		private var _dataProvider: *;
		private var _displaySocket: IDisplaySocket;
		
		public function FillSocketAct(displayPath: String=null, dataProvider: *=null){
			super();
			this.displayPath = displayPath;
			this.dataProvider = dataProvider;
		}
		
		public function get displayPath(): String
		{
			return this._displayPath;
		}
		public function set displayPath(value: String): void
		{
			this._displayPath = value;
		}
		
		public function get displaySocket():IDisplaySocket
		{
			return this._displaySocket;
		}
		public function set displaySocket(value: IDisplaySocket): void
		{
			this._displaySocket = value;
		}
		
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