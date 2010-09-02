package org.farmcode.display.layout
{
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.binding.PropertyWatcher;
	import org.farmcode.binding.Watchable;
	import org.farmcode.display.core.IView;
	import org.farmcode.display.layout.core.ILayoutInfo;
	import org.farmcode.display.validation.FrameValidationFlag;
	import org.farmcode.display.validation.ValidationFlag;
	
	public class AbstractLayout extends Watchable implements ILayout, ILayoutSubject
	{
		
		private const scopeView_name:String = "scopeView";
		
		public function get scopeView():IView{return _get(scopeView_name);}
		public function set scopeView(value:IView):void{_set(scopeView_name,value);}
		public function get scopeViewChanged():IAct{return _getAct(scopeView_name);}
		
		
		
		public function get layoutInfo():ILayoutInfo{
			return _layoutInfo;
		}
		public function set layoutInfo(value:ILayoutInfo):void{
			_layoutInfo = value;
		}
		
		public function get displayPosition():Rectangle{
			return _displayPosition;
		}
		public function get measurements():Point{
			_measureFlag.validate();
			return _measurements;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get measurementsChanged():IAct{
			if(!_measurementsChanged)_measurementsChanged = new Act();
			return _measurementsChanged;
		}
		/**
		 * @inheritDoc
		 */
		public function get positionChanged():IAct{
			if(!_positionChanged)_positionChanged = new Act();
			return _positionChanged;
		}
		
		protected var _positionChanged:Act;
		protected var _measurementsChanged:Act;
		protected var _measureFlag:ValidationFlag; 
		
		protected var _layoutInfo:ILayoutInfo;
		protected var _displayPosition:Rectangle = new Rectangle();
		protected var _measurements:Point;
		protected var _subjects:Dictionary = new Dictionary();
		
		private var _drawFlag:FrameValidationFlag;
		
		public function AbstractLayout(scopeView:IView){
			super([scopeView_name]);
			new PropertyWatcher(scopeView_name,setScopeView,null,null,this);
			
			_drawFlag = new FrameValidationFlag(null,draw,false);
			this.scopeView = scopeView;
			_measureFlag = new ValidationFlag(measure, false);
			_measurements = new Point();
		}
		protected function setScopeView(value:IView):void{
			_drawFlag.view = value;
		}
		/* If this returns true then the measure function must
		be overrdien, if it returns false then the draw function must
		perform the measuring.
		*/
		protected function drawToMeasure() : Boolean{
			return true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function addSubject(subject:ILayoutSubject):Boolean{
			if(!_subjects[subject]){
				_subjects[subject] = true;
				subject.measurementsChanged.addHandler(onSubjectMeasChanged);
				return true;
			}
			return false;
		}
		/**
		 * @inheritDoc
		 */
		public function removeSubject(subject:ILayoutSubject):Boolean{
			if(_subjects[subject]){
				delete _subjects[subject];
				subject.measurementsChanged.removeHandler(onSubjectMeasChanged);
				return true;
			}
			return false;
		}
		public function setLayoutSize(x:Number, y:Number, width:Number, height:Number):void{
			setDisplayPosition(x, y, width, height);
		}
		public function setDisplayPosition(x:Number, y:Number, width:Number, height:Number):void{
			if(_positionChanged){
				var oldX:Number = _displayPosition.x;
				var oldY:Number = _displayPosition.y;
				var oldWidth:Number = _displayPosition.width;
				var oldHeight:Number = _displayPosition.height;
			}
			var change:Boolean = false;
			if(_displayPosition.x!=x){
				_displayPosition.x = x;
				change = true;
			}
			if(_displayPosition.y!=y){
				_displayPosition.y = y;
				change = true;
			}
			if(_displayPosition.width!=width){
				_displayPosition.width = width;
				change = true;
			}
			if(_displayPosition.height!=height){
				_displayPosition.height = height;
				change = true;
			}
			if(change){
				invalidate();
				if(_positionChanged)_positionChanged.perform(this,oldX,oldY,oldWidth,oldHeight);
			}
		}
		
		protected function invalidate(): void{
			_drawFlag.invalidate();
		}
		public function validate(forceDraw: Boolean = false): void{
			if(forceDraw)invalidate();
			_drawFlag.validate(forceDraw);
		}
		
		protected function onSubjectMeasChanged(from:ILayoutSubject, oldWidth:Number, oldHeight:Number): void{
			// override me
		}
		protected function doMeasurementsChanged(): void{
			_measureFlag.invalidate();
			if(_measurementsChanged)_measurementsChanged.perform(this, _measurements.x, _measurements.y);
		}
		protected function measure() : void{
			if(drawToMeasure()){
				validate(true);
			}
		}
		protected function draw(): void{
		}
	}
}