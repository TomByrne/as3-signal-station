package au.com.thefarmdigital.display.views
{
	import au.com.thefarmdigital.display.View;
	import au.com.thefarmdigital.display.controls.Control;
	import au.com.thefarmdigital.events.ControlEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.farmcode.display.constants.Anchor;
	import org.farmcode.display.constants.Direction;

	public class StackView extends Container{
		
		public function get direction():String{
			return _direction;
		}
		public function set direction(value:String):void{
			if(_direction!=value){
				_direction = value;
				invalidate();
			}
		}
		public function get anchor():String{
			return _anchor;
		}
		public function set anchor(value:String):void{
			if(_anchor!=value){
				_anchor = value;
				invalidate();
			}
		}
		[Inspectable(name="Gap", type="Number", defaultValue="0")]
		public function get gap():Number{
			return _gap;
		}
		public function set gap(value:Number):void{
			if(_gap!=value){
				_gap = value;
				invalidate();
			}
		}
		public function get allowAutoSize():Boolean{
			return _allowAutoSize;
		}
		public function set allowAutoSize(value:Boolean):void{
			if(_allowAutoSize!=value){
				_allowAutoSize = value;
				invalidate();
				this.invalidateMeasurements();
			}
		}
		public function get stackLength():Number{
			return container.numChildren;
		}
		
		protected var _gap:Number = 0;
		protected var _direction:String = Direction.VERTICAL;
		protected var _anchor:String = Anchor.CENTER;
		protected var _allowAutoSize:Boolean = false;
		
		override protected function removeCompiledClips():void{
			var children:Array = [];
			var lastX:Number = 0;
			var lastY:Number = 0;
			var votesH:int = 0;
			var votesV:int = 0;
			for(var i:int=0; i<numChildren; ++i){
				var child:DisplayObject = getChildAt(i);
				if(child && child!=backing){
					if(child is Control){
						if(children.length){
							var diffX:Number = Math.abs(child.x-lastX);
							var diffY:Number = Math.abs(child.y-lastY);
							if(diffX>diffY){
								votesH++;
							}else if(diffX<diffY){
								votesV++;
							}
						}
						lastX = child.x;
						lastY = child.y;
						children.push(child);
					}
				}
			}
			if(votesH>votesV){
				direction = Direction.HORIZONTAL;
				children.sortOn("x",Array.NUMERIC);
			}else{
				direction = Direction.VERTICAL;
				children.sortOn("y",Array.NUMERIC);
			}
			var length:int = children.length;
			for(i=0; i<length; ++i){
				child = children[i];
				removeChild(child);
				container.addChild(child);
			}
		}
		
		override protected function measure():void
		{
			this.validate();
		}
		override protected function draw():void{
			super.draw();
			var contDims:Point = new Point(width-leftPadding-rightPadding,height-topPadding-bottomPadding);
			var props:Array = [{coord:"x",dim:"width",align:(_anchor.indexOf("L")!=-1?-1:(_anchor.indexOf("R")!=-1?1:0))},
								{coord:"y",dim:"height",align:(_anchor.indexOf("T")!=-1?-1:(_anchor.indexOf("B")!=-1?1:0))}];
			var stackDim:Number;
			var otherDim:Number;
			
			if(_direction==Direction.VERTICAL){
				stackDim = 1;
				otherDim = 0;
			}else{
				stackDim = 0;
				otherDim = 1;
			}
			var alignRange:Number = 0;
			var preemptStack:Number = 0;
			var length:int = container.numChildren;
			for(var i:int=0; i<length; ++i){
				var child:DisplayObject = container.getChildAt(i);
				if(_allowAutoSize && child is Control){
					var con:Control = (child as Control);
					if(!isNaN(con.measuredWidth))con.width = con.measuredWidth;
					if(!isNaN(con.measuredHeight))con.height = con.measuredHeight;
					con.validate();
				}
				var measurement:Point = measureChild(i,child);
				alignRange = Math.max(alignRange,measurement[props[otherDim].coord]);
				preemptStack += (measurement[props[stackDim].coord])+gap;
			}
			var stack:Number = 0;
			if(props[stackDim].align==0){
				stack = Math.max(0,(contDims[props[stackDim].coord]-preemptStack)/2);
			}else if(props[stackDim].align==1){
				stack = contDims[props[stackDim].coord]-preemptStack;
			}
			for(i=0; i<length; ++i){
				child = container.getChildAt(i);
				child[props[stackDim].coord] = stack;
				if(props[otherDim].align==-1){
					child[props[otherDim].coord] = 0;
				}else if(props[otherDim].align==1){
					child[props[otherDim].coord] = alignRange-child[props[otherDim].dim];
				}else{
					child[props[otherDim].coord] = (alignRange-child[props[otherDim].dim])/2;
				}
				
				stack += (child[props[stackDim].dim])+gap;
			}
			if(allowDrawMeasurement()){
				if(_direction==Direction.VERTICAL){
					_measuredWidth = alignRange;
					_measuredHeight = stack;
				}else{
					_measuredWidth = stack;
					_measuredHeight = alignRange;
				}
			}
		}
		protected function allowDrawMeasurement():Boolean{
			return true;
		}
		protected function measureChild(index:Number, child:DisplayObject):Point{
			return new Point(child.width,child.height);
		}
		public function getStackItem(index:Number):DisplayObject{
			return container.getChildAt(index);
		}
		public function addToStack(display:DisplayObject, at:int=-1):void{
			if(display.parent!=container){
				if(display.parent)display.parent.removeChild(display);
				if(at>=0)container.addChildAt(display,at);
				else container.addChild(display);
				
				var cast:View = (display as View);
				if(cast){
					cast.addEventListener(ControlEvent.MEASUREMENTS_CHANGE, onChildMeasurementsChange);
				}
				invalidateMeasurements();
				validate(true);
			}
		}
		protected function onChildMeasurementsChange(e:Event):void{
			invalidateMeasurements();
			if(allowAutoSize)invalidate();
		}
		public function removeAllFromStack():void{
			while(container.numChildren){
				var child:DisplayObject = container.removeChildAt(0);
				var cast:View = (child as View);
				if(cast){
					cast.removeEventListener(ControlEvent.MEASUREMENTS_CHANGE, onChildMeasurementsChange);
				}
			}
			invalidateMeasurements();
			invalidate();
		}
		public function removeFromStack(display:DisplayObject):void{
			var child:DisplayObject = container.removeChild(display);
			var cast:View = (child as View);
			if(cast){
				cast.removeEventListener(ControlEvent.MEASUREMENTS_CHANGE, onChildMeasurementsChange);
			}
			invalidateMeasurements();
			invalidate();
		}
		public function removeFromStackAt(index:int):void{
			var child:DisplayObject = container.removeChildAt(index);
			var cast:View = (child as View);
			if(cast){
				cast.removeEventListener(ControlEvent.MEASUREMENTS_CHANGE, onChildMeasurementsChange);
			}
			invalidateMeasurements();
			invalidate();
		}
		public function executeOnStackChildren(func:Function):void{
			validate();
			var length:int = container.numChildren;
			for(var i:int=0; i<length; ++i){
				func(container.getChildAt(i));
			}
		}
	}
}