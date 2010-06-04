package au.com.thefarmdigital.debug.debugNodes
{
	import au.com.thefarmdigital.debug.events.InfoSourceEvent;
	import au.com.thefarmdigital.debug.infoSources.IEditableTextInfoSource;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	public class TextInputDebugNode extends AbstractVisualDebugNode
	{
		override public function set selected(value:Boolean): void{
			if(super.selected != value){
				super.selected = value;
				validateSelected();
			}
		}
		
		public function get infoSource():IEditableTextInfoSource{
			return _infoSource;
		}
		public function set infoSource(value:IEditableTextInfoSource):void{
			if(_infoSource!=value){
				if(_infoSource){
					_infoSource.removeEventListener(InfoSourceEvent.INFO_CHANGE, onInfoChange);
				}
				_infoSource = value;
				if(_infoSource){
					_infoSource.addEventListener(InfoSourceEvent.INFO_CHANGE, onInfoChange);
					_textField.text = _infoSource.textOutput;
				}
			}
		}
		
		private var _infoSource:IEditableTextInfoSource;
		private var _textField:TextField;
		
		public function TextInputDebugNode(infoSource:IEditableTextInfoSource=null, width:Number=100, height:Number=18)
		{
			
			_textField = new TextField();
			_textField.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			addChild(_textField);
			this.width = width;
			this.height = height;
			this.appearAsButton = true;
			
			this.infoSource = infoSource;
		}
		protected function validateSelected():void{
			if(selected){
				_textField.background = true;
				_textField.type = TextFieldType.INPUT;
				_textField.visible = selected;
				if(_textField.stage){
					_textField.stage.focus = _textField;
					_textField.setSelection(0,_textField.text.length-1);
				}
				_textField.setTextFormat(new TextFormat("_sans",10,0));
			}else{
				_textField.background = false;
				_textField.type = TextFieldType.DYNAMIC;
				_textField.setTextFormat(new TextFormat("_sans",10,0xffffff));
				_textField.text = _infoSource.textOutput;
			}
		}
		protected function onInfoChange(e:Event):void{
			if(_textField.text!=_infoSource.textOutput){
				_textField.text = _infoSource.textOutput;
			}
		}
		protected function onKeyDown(e:KeyboardEvent):void{
			if(e.charCode==Keyboard.ENTER){
				_infoSource.setTextOutput(_textField.text);
				selected = false;
			}
		}
		override protected function draw() : void{
			_textField.width = width;
			_textField.height = height;
		}
	}
}