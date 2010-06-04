package au.com.thefarmdigital.display.controls
{
	import au.com.thefarmdigital.events.ControlEvent;
	
	public class TextArea extends Control
	{
		public function get editable():Boolean{
			return _editable;
		}
		public function set editable(value:Boolean):void{
			if(value!=_editable){
				_editable = value;
				if(_textInput)_textInput.active = value;
			}
		}
		public function get text():String{
			return _text;
		}
		public function set text(value:String):void{
			if(value!=_text){
				_text = value;
				if(_textInput)_textInput.text = value;
			}
		}
		public function get textInput():TextInput{
			return _textInput;
		}
		public function set textInput(value:TextInput):void{
			if(value!=_textInput){				
				_textInput = value;
				_textInput.text = _text;
				_textInput.active = _editable;
				_textInput.multiline = true;
				if(_scrollBar)_scrollBar.scrollSubject = _textInput;
			}
		}
		public function get scrollBar():ScrollBar{
			return _scrollBar;
		}
		public function set scrollBar(value:ScrollBar):void{
			if(value!=_scrollBar){
				_scrollBar = value
				if(_textInput)_scrollBar.scrollSubject = _textInput;
			}
		}
		
		private var _scrollBar:ScrollBar;
		private var _textInput:TextInput;
		private var _text:String;
		private var _editable:Boolean = true;
		
		public function TextArea(){
			super();
		}
		override protected function draw():void{
			if(_textInput){
				_textInput.height = height;
				if(_scrollBar){
					_scrollBar.height = height;
					_textInput.width = _scrollBar.x = width-_scrollBar.measuredWidth;
					_scrollBar.width = _scrollBar.measuredWidth;
				}else{
					_textInput.width = width;
				}
			}
		}
	}
}