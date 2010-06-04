package au.com.thefarmdigital.display.form
{
	import au.com.thefarmdigital.display.controls.CheckBox;
	import au.com.thefarmdigital.events.ControlEvent;
	
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class CheckBoxGroup
	{
		public function get minimumSelected():Number{
			return _minimumSelected;
		}
		public function set minimumSelected(value:Number):void{
			if(_minimumSelected != value){
				_minimumSelected = value;
				checkSelection();
			}
		}
		public function get maximumSelected():Number{
			return _maximumSelected;
		}
		public function set maximumSelected(value:Number):void{
			if(_maximumSelected != value){
				_maximumSelected = value;
				checkSelection();
			}
		}
		public function get selectedCheckBoxes():Array{
			var ret:Array = [];
			var length:int = checkBoxes.length;
			for(var i:int=0; i<length; ++i){
				var checkBox:CheckBox = checkBoxes[i];
				if(checkBox.selected){
					ret.push(checkBox);
				}
			}
			return ret;
		}
		public function set selectedCheckBoxes(value:Array):void{
			var length:int = checkBoxes.length;
			for(var i:int=0; i<length; ++i){
				var checkBox:CheckBox = checkBoxes[i];
				checkBox.selected = (value.indexOf(checkBox)!=-1);
			}
			culprits = value;
			checkSelection();
		}
		public function get selectedData():Array{
			return getData(selectedCheckBoxes);
		}
		public function set selectedData(value:Array):void{
			selectedCheckBoxes = resolveData(value);
		}
		
		protected var checkBoxes:Array = [];	
		protected var _minimumSelected:int = 0;
		protected var _maximumSelected:int = 1;
		protected var culprits:Array = [];
		protected var confirming:Boolean = false;
		
		public function CheckBoxGroup(checkBoxes:Array=null){
			if(checkBoxes){
				var length:int = checkBoxes.length;
				for(var i:int=0; i<length; ++i){
					addCheckBox(checkBoxes[i]);
				}
				checkSelection();
			}
		}
		public function addCheckBox(checkBox:CheckBox):void{
			checkBoxes.push(checkBox);
			checkBox.addEventListener(ControlEvent.BUTTON_TOGGLE,onCheckBoxToggle);
			checkBox.addEventListener(FocusEvent.FOCUS_IN,onCheckBoxFocusIn);
			checkBox.addEventListener(FocusEvent.FOCUS_OUT,onCheckBoxFocusOut);
		}
		public function removeCheckBox(checkBox:CheckBox):void{
			var length:int = checkBoxes.length;
			for(var i:int=0; i<length; ++i){
				if(checkBoxes[i]==checkBox){
					checkBoxes.splice(i,1);
					break;
				}
			}
		}
		protected function onCheckBoxToggle(e:ControlEvent):void{
			if(!confirming){
				var checkBox:CheckBox = (e.currentTarget as CheckBox);
				culprits.unshift(checkBox);
				checkSelection();
			}
		}
		protected function onCheckBoxFocusIn(e:FocusEvent):void{
			var checkBox:CheckBox = (e.currentTarget as CheckBox);
			if(checkBox.stage){
				checkBox.stage.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			}
		}
		protected function onCheckBoxFocusOut(e:FocusEvent):void{
			var checkBox:CheckBox = (e.currentTarget as CheckBox);
			if(checkBox.stage){
				checkBox.stage.removeEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			}
		}
		protected function onKeyUp(e:KeyboardEvent):void{
			if(e.charCode == Keyboard.DOWN || e.charCode == Keyboard.RIGHT){
				//focusInGroup(this,1);
			}else if(e.charCode == Keyboard.UP || e.charCode == Keyboard.LEFT){
				//focusInGroup(this,-1);
			}
		}
		protected function checkSelection():void{
			confirming = true;
			if(!culprits)culprits = [];
			var i:int;
			var selected:Number = 0;
			var innocent:Array = [];
			var checkBox:CheckBox;
			var length:int = checkBoxes.length;
			for(i=0; i<length; ++i){
				checkBox = checkBoxes[i];
				if(checkBox.selected)selected++;
				if(culprits.indexOf(checkBox)==-1){
					innocent.push(checkBox);
				}
			}
			length = innocent.length;
			for(i=-culprits.length; i<length; ++i){
				checkBox = (i>=0?innocent[i]:culprits[Math.abs(i)-1]);
				if(selected<_minimumSelected && !checkBox.selected){
					checkBox.selected = true;
					selected++;
					if(i>=0)culprits.push(checkBox);
				}else if(selected>_maximumSelected && checkBox.selected){
					checkBox.selected = false;
					selected--;
					if(i<0)culprits.splice(Math.abs(i)-1,1);
				}
				if(selected>=_minimumSelected && selected<=_maximumSelected){
					break;
				}
			}
			confirming = false;
		}
		protected function resolveData(dataArray:Array):Array{
			var ret:Array = [];
			var length:int = dataArray.length;
			for(var j:int=0; j<length; ++j){
				var data:* = dataArray[j];
				var length2:int = checkBoxes.length;
				for(var i:int=0; i<length2; ++i){
					var checkBox:CheckBox = checkBoxes[i];
					if(checkBox.data==data){
						ret.push(checkBox);
						break;
					}
				}
			}
			return ret;
		}
		protected function getData(checkBoxes:Array):Array{
			var ret:Array = [];
			var length:int = checkBoxes.length;
			for(var i:int=0; i<length; ++i){
				var checkBox:CheckBox = checkBoxes[i];
				ret.push(checkBox.data);
			}
			return ret;
		}
	}
}