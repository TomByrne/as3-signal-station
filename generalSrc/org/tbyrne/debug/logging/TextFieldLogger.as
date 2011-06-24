package org.tbyrne.debug.logging
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import org.tbyrne.display.assets.nativeAssets.NativeAssetFactory;
	import org.tbyrne.display.assets.nativeTypes.IDisplayObjectContainer;
	import org.tbyrne.display.assets.nativeTypes.ITextField;

	public class TextFieldLogger extends AbstractLogger implements ILogger
	{
		
		public function get parent():IDisplayObjectContainer{
			return _parent;
		}
		public function set parent(value:IDisplayObjectContainer):void{
			if(_parent!=value){
				if(_parent){
					_parent.removeAsset(_textFieldAsset);
					_parent.added.removeHandler(onChildAdded);
				}
				_parent = value;
				if(_parent){
					if(!_textFieldAsset){
						var factory:NativeAssetFactory = new NativeAssetFactory();
						_textFieldAsset = factory.getNew(_textField);
					}
					_parent.addAsset(_textFieldAsset);
					_parent.added.addHandler(onChildAdded);
				}
			}
		}
		public function get textField():TextField{
			return _textField;
		}
		
		private var _parent:IDisplayObjectContainer;
		
		private var _open:Boolean = false;
		private var _textField:TextField;
		private var _textFieldAsset:ITextField;
		
		public function TextFieldLogger(parent:IDisplayObjectContainer=null){
			super();
			
			_textField = new TextField();
			_textField.width = 5;
			_textField.height = 5;
			_textField.background = true;
			_textField.border = true;
			_textField.doubleClickEnabled = true;
			_textField.addEventListener(MouseEvent.DOUBLE_CLICK, onClick);
			_textField.alpha = 0.5;
			_textField.multiline = true;
			
			this.parent = parent;
		}
		
		protected function onClick(event:MouseEvent):void{
			_open = !_open;
			if(_open){
				_textField.width = _textField.stage.stageWidth;
				_textField.height = _textField.stage.stageHeight;
			}else{
				_textField.width = 5;
				_textField.height = 5;
			}
		}
		
		public function log(level:int, ...params):void{
			var levelName:String = getLevelName(level);
			var colour:Number = getLevelColour(level);
			var entry:String = "<font color='#"+colour.toString(16)+"'>"+[levelName].concat(params).join(" ")+"</font>";
			if(_textField.text.length)entry = "\n"+entry;
			_textField.htmlText += entry;
		}
		
		protected function onChildAdded(e:Event, from:IDisplayObjectContainer):void{
			_parent.setAssetIndex(_textFieldAsset,_parent.numChildren-1);
		}
		
	}
}