package au.com.thefarmdigital.debug.debugNodes
{
	import au.com.thefarmdigital.debug.events.InfoSourceEvent;
	import au.com.thefarmdigital.debug.infoSources.ITextInfoSource;
	
	import flash.events.Event;

	public class LabelDebugNode extends AbstractDebugNode
	{
		private var _outputFormat: String;
		private var _infoSource: ITextInfoSource;
		
		public function LabelDebugNode(infoSource:ITextInfoSource = null, outputFormat: String = null){
			super();
			this.outputFormat = outputFormat;
			this.infoSource = infoSource;
		}
		
		[Property(clonable="true")]
		public function get outputFormat(): String{
			return this._outputFormat;
		}
		public function set outputFormat(value: String): void{
			this._outputFormat = value;
		}
		[Property(clonable="true")]
		public function get infoSource(): ITextInfoSource{
			return _infoSource;
		}
		public function set infoSource(value: ITextInfoSource): void{
			if(_infoSource != value){
				_infoSource = value;
				_infoSource.addEventListener(InfoSourceEvent.INFO_CHANGE, onInfoChange);
			}
		}
		override public function get labelColour():Number{
			return _infoSource?_infoSource.labelColour:super.labelColour;
		}
		protected function onInfoChange(e:Event):void{
			dispatchNodeChange();
		}
		override public function get label() : String{
			var targetText: String = null;
			if(_infoSource){
				targetText = _infoSource.textOutput;
			}else if(outputFormat){
				return outputFormat;
			}
			
			if (targetText == null){
				targetText = "";
			}
			var output: String = null;
			if (this.outputFormat == null){
				output = targetText;
			}else{
				output = this.outputFormat.replace("%s", targetText);
			} 
			return output;
		}
	}
}