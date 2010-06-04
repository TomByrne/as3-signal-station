package au.com.thefarmdigital.display.controls{
	
	import au.com.thefarmdigital.display.View;
	import au.com.thefarmdigital.validation.IValidatable;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Matrix;
	
	/**
	 * The Control class is the superclass of all Controls and Containers in the farm library, it adds pixel snapping.
	 * It adds the ability to function within the Form class, with the formIndex, validator and setFocus() members.
	 */
	public class Control extends View implements IValidatable{
		override public function get x():Number{
			return super.x;
		}
		override public function set x(value:Number):void{
			snap(value,NaN);
		}
		override public function get y():Number{
			return super.y;
		}
		override public function set y(value:Number):void{
			snap(NaN,value);
		}
		override public function set scaleY(value:Number):void{
			if(_allowScale)super.scaleY = value;
		}
		override public function set scaleX(value:Number):void{
			if(_allowScale)super.scaleX = value;
		}
		[Inspectable(name="Form Index")]
		public function get formIndex():Number{
			return _formIndex;
		}
		public function set formIndex(value:Number):void{
			_formIndex = value;
		}
		[Inspectable(name="Pixel Snapping")]
		public function get pixelSnapping():Boolean{
			return _pixelSnapping;
		}
		public function set pixelSnapping(value:Boolean):void{
			_pixelSnapping = value;
		}
		public function get highlit():Boolean{
			return _highlit;
		}
		public function set highlit(value:Boolean):void{
			if(_highlit != value){
				_highlit = value;
				invalidate();
			}
		}
		
		public function get data():*{
			return _data;
		}
		public function set data(value:*):void{
			_data = value;
		}
		public function get allowScale():Boolean{
			return _allowScale;
		}
		public function set allowScale(value:*):void{
			_allowScale = value;
		}
		
		protected var _formIndex:int = -1;
		protected var _data:*;
		protected var _allowScale:Boolean = false;
		
		protected var _pixelSnapping:Boolean = true;
		protected var _highlit:Boolean;
		private var pendingAdds:Array = [];
		
		public function Control(){
			super();
			
			tabEnabled = false;
			
			snap();
			
			commitHeirarchy();
		}
		protected function commitHeirarchy():void{
			var length:int = pendingAdds.length;
			for(var i:int=0; i<length; ++i){
				var pendingAdd:PendingChildAdd = pendingAdds[i];
				addChildTo(pendingAdd.parent, pendingAdd.child);
			}
			pendingAdds = null;
		}
		public function setFocus():void{
		}
		protected function snap(x:Number=NaN,y:Number=NaN):void{
			if(!isNaN(x))super.x = x;
			if(!isNaN(y))super.y = y;
			if(transform.matrix){
				if(_pixelSnapping){
					var matrix:Matrix = transform.concatenatedMatrix;
					super.x = super.x-(matrix.tx-Math.round(matrix.tx));
					super.y = super.y-(matrix.ty-Math.round(matrix.ty));
				}
			}
		}
		public function clear():void{
			
		}
		protected function addChildTo(parent:DisplayObjectContainer, child:DisplayObject):void{
			if(childrenConstructed){
				if(child.parent && child.parent!=parent)child.parent.removeChild(child);
				if(!child.parent)parent.addChild(child);
			}else{
				pendingAdds.push(new PendingChildAdd(parent, child));
			}
		}
		
		// IValidatable implementation
		public function getValidationValue(validityKey:String=null):*{
			return data;
		}
		public function setValidationValue(value:*, validityKey:String=null):void{
			data = value;
		}
		public function setValid(valid:Boolean, validityKey:String=null):void{
			highlit = !valid;
		}
	}
}
import flash.display.DisplayObjectContainer;
import flash.display.DisplayObject;
	
class PendingChildAdd{
	public var parent:DisplayObjectContainer;
	public var child:DisplayObject;
	public function PendingChildAdd(parent:DisplayObjectContainer, child:DisplayObject){
		this.parent = parent;
		this.child = child;
	}
}