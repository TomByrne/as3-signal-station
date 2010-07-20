package org.farmcode.display.utils
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.farmcode.display.DisplayNamespace;
	import org.farmcode.display.actInfo.IMouseActInfo;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.assets.IInteractiveObjectAsset;
	import org.farmcode.display.assets.ITextFieldAsset;
	import org.farmcode.display.controls.TextLabel;
	import org.farmcode.display.core.DrawableView;
	
	use namespace DisplayNamespace;
	
	/**
	 * Adds 'Insert' behaviour to TextInputs (i.e. where there is always one
	 * character selected when typing).
	 */
	public class TextFieldSelectionBehaviour extends DrawableView
	{
		public function get skipCharSelection():String{
			return _skipCharSelection;
		}
		public function set skipCharSelection(value:String):void{
			if(_skipCharSelection!=value){
				_skipCharSelection = value;
				if(_textField)assessSelection();
			}
		}
		public function get replaceMode():Boolean{
			return _replaceMode;
		}
		public function set replaceMode(value:Boolean):void{
			if(_replaceMode!=value){
				_replaceMode = value;
				if(_textField)assessSelection();
			}
		}
		
		public function get allowMultiCharSelect():Boolean{
			return _allowMultiCharSelect;
		}
		public function set allowMultiCharSelect(value:Boolean):void{
			if(_allowMultiCharSelect!=value){
				_allowMultiCharSelect = value;
				if(_textField)assessSelection();
			}
		}
		
		public var allowAddToStart:Boolean = true;
		public var allowAddToEnd:Boolean = true;
		
		protected var _replaceMode:Boolean = false;
		protected var _allowMultiCharSelect:Boolean = true;
		protected var _skipCharSelection:String;
		protected var _textField:ITextFieldAsset;
		protected var _lastBegin:int;
		
		public function TextFieldSelectionBehaviour(asset:IDisplayAsset=null){
			super(asset);
		}
		override protected function bindToAsset() : void{
			_textField = _containerAsset.takeAssetByName(TextLabel.LABEL_FIELD_CHILD, ITextFieldAsset);
			_textField.clicked.addHandler(onClick);
			_textField.keyUp.addHandler(onKeyUp);
			_textField.focusIn.addHandler(onFocusIn);
			assessSelection();
		}
		override protected function unbindFromAsset() : void{
			_textField.clicked.removeHandler(onClick);
			_textField.keyUp.removeHandler(onKeyUp);
			_textField.focusIn.removeHandler(onFocusIn);
			_containerAsset.returnAsset(_textField);
			_textField = null;
		}
		
		protected function assessSelection():void{
			if(_textField.text.length){
				var begin:int = _textField.selectionBeginIndex;
				var end:int = _textField.selectionEndIndex;
				if(begin==end && _replaceMode){
					end = begin+1;
				}
				var min:int = 0;
				for(; _skipCharSelection.indexOf(_textField.text.charAt(min))!=-1; ++min){}
				var max:int = _textField.text.length;
				
				for(; _skipCharSelection.indexOf(_textField.text.charAt(max-1))!=-1; --max){}
				
				var maxStart:int = allowAddToStart || !_replaceMode?max:max-1;
				var minEnd:int = allowAddToEnd || !_replaceMode?min:min+1;
				
				if(_skipCharSelection){
					var dir:int = (_lastBegin>begin?-1:1);
					if(begin!=end){
						while(!found){
							for(var i:int=begin; i<end; i++){
								var found:Boolean;
								if(_skipCharSelection.indexOf(_textField.text.charAt(i))==-1){
									found = true;
									break;
								}
							}
							if(!found){
								if(begin+dir<min){
									begin = min;
								}else if(begin+dir>maxStart){
									begin = maxStart;
									found = true;
								}else{
									begin += dir;
								}
								if(end+dir<minEnd){
									end = minEnd;
									found = true;
								}else if(end+dir>max){
									end = max;
								}else{
									end += dir;
								}
							}
						}
					}
				}
				if(begin<min){
					begin = min;
				}else if(begin>maxStart){
					begin = maxStart;
					found = true;
				}
				if(end<minEnd){
					end = minEnd;
					found = true;
				}else if(end>max){
					end = max;
				}
				_textField.setSelection(begin,end);
				_lastBegin = begin;
			}
		}
		
		protected function onFocusIn(e:Event, from:IInteractiveObjectAsset):void{
			assessSelection();
		}
		protected function onClick(from:IInteractiveObjectAsset, info:IMouseActInfo):void{
			assessSelection();
		}
		protected function onKeyUp(e:KeyboardEvent, from:IInteractiveObjectAsset):void{
			if(_replaceMode &&
				(e.keyCode==Keyboard.LEFT || e.keyCode==Keyboard.BACKSPACE) &&
				_textField.selectionEndIndex<=_textField.selectionBeginIndex+1){
				_textField.setSelection(_textField.selectionBeginIndex-1,_textField.selectionEndIndex);
			}
			assessSelection();
		}
	}
}