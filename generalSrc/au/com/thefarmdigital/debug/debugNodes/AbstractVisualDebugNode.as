package au.com.thefarmdigital.debug.debugNodes
{
	import au.com.thefarmdigital.debug.events.DebugNodeEvent;
	import au.com.thefarmdigital.debug.toolbar.IDebugToolbar;
	import au.com.thefarmdigital.display.View;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	[Event(name="nodeChange", type="au.com.thefarmdigital.debug.events.DebugNodeEvent")]
	public class AbstractVisualDebugNode extends View implements IDebugNode
	{
		private var _updateTime:Number;
		private var _updateTimer:Timer;
		private var _parentToolbar: IDebugToolbar;
		private var _childNodes: Array;
		private var _appearAsButton:Boolean;
		private var _selected:Boolean;
		
		public function get appearAsButton():Boolean{
			return _appearAsButton;
		}
		public function set appearAsButton(value:Boolean):void{
			if(_appearAsButton!=value){
				_appearAsButton = value;
				dispatchNodeChange();
			}
		}
		public function get icon():DisplayObject{
			return this;
		}
		
		public function get label():String{
			return null;
		}
		public function get labelColour():Number{
			return 0xffffff;
		}
		
		public function set selected(value:Boolean): void{
			_selected = value;
		}
		public function get selected(): Boolean{
			return this._selected;
		}
		public function set parentToolbar(value: IDebugToolbar): void{
			if (this.parentToolbar != value){
				this._parentToolbar = value;
				this.invalidate();
			}
		}
		public function get parentToolbar(): IDebugToolbar{
			return this._parentToolbar;
		}
		public function set childNodes(value: Array): void{
			if (this._childNodes != value){
				this._childNodes = value;
				dispatchNodeChange();
			}
		}
		public function get childNodes(): Array{
			return this._childNodes;
		}
		
		[Property(clonable="true")]
		public function get updateTime(): Number{
			return _updateTime;
		}
		public function set updateTime(value: Number): void{
			if(_updateTime!=value){
				_updateTime = value;
				if(isNaN(_updateTime)){
					_updateTimer.removeEventListener(TimerEvent.TIMER, onUpdateTimer);
					_updateTimer = null;
				}else{
					_updateTimer = new Timer(value*1000);
					_updateTimer.addEventListener(TimerEvent.TIMER, onUpdateTimer);
					_updateTimer.start();
				}
			}
		}
		protected function onUpdateTimer(e:Event):void{
			dispatchNodeChange();
		}
		protected function dispatchNodeChange():void{
			dispatchEvent(new DebugNodeEvent(DebugNodeEvent.NODE_CHANGE));
		}
	}
}