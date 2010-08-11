package org.farmcode.display.layout
{
	
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.display.assets.IDisplayAsset;
	import org.farmcode.display.core.IView;
	import org.farmcode.display.core.View;
	import org.farmcode.display.layout.core.ILayoutInfo;
	import org.farmcode.display.validation.FrameValidationFlag;
	import org.farmcode.display.validation.ValidationFlag;
	
	public class AbstractLayout implements ILayout, ILayoutSubject
	{
		
		public function get scopeView():IView{
			return _drawFlag.view;
		}
		public function set scopeView(value:IView):void{
			_drawFlag.view = value;
		}
		
		
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
		protected var _measurements:Point = new Point();
		protected var _subjects:Dictionary = new Dictionary();
		protected var _invalidSubjects:Dictionary = new Dictionary();
		protected var _allInvalid:Boolean;
		
		private var _marginAffectedArea:Rectangle = new Rectangle();
		private var _marginRect:Rectangle = new Rectangle();
		
		private var _drawFlag:FrameValidationFlag;
		
		public function AbstractLayout(scopeView:IView){
			_drawFlag = new FrameValidationFlag(null,commitDraw,false);
			this.scopeView = scopeView;
			_measureFlag = new ValidationFlag(measure, false);
			_measureFlag.invalidateAct.addHandler(onMeasInvalidate);
		}
		
		public function addSubject(subject:ILayoutSubject):void{
			if(!_subjects[subject]){
				_subjects[subject] = true;
				subject.measurementsChanged.addHandler(onMeasumentsChange);
				invalidateSingle(subject);
			}
		}
		public function removeSubject(subject:ILayoutSubject):void{
			if(_subjects[subject]){
				delete _subjects[subject];
				delete _invalidSubjects[subject];
				subject.measurementsChanged.removeHandler(onMeasumentsChange);
			}
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
				invalidateAll();
				if(_positionChanged)_positionChanged.perform(this,oldX,oldY,oldWidth,oldHeight);
			}
		}
		
		protected function invalidateSingle(subject:ILayoutSubject): void{
			if(!_allInvalid){
				_invalidSubjects[subject] = true;
				invalidate();
			}
		}
		protected function invalidateAll(): void{
			if(!_allInvalid){
				_allInvalid = true;
				for(var i:* in _invalidSubjects){
					_invalidSubjects = new Dictionary();
					break;
				}
				invalidate();
			}
		}
		public function invalidate(): void{
			_drawFlag.invalidate();
		}
		public function validate(forceDraw: Boolean = false): void{
			if(forceDraw)invalidate();
			_drawFlag.validate(forceDraw);
		}
		
		protected function onMeasumentsChange(from:ILayoutSubject, oldWidth:Number, oldHeight:Number): void{
			invalidateSingle(from);
		}
		/**
		 * @inheritDoc
		 */
		final public function commitDraw(): void{
			draw();
		}
		protected function draw(): void{
			var drawList:Dictionary;
			if(_allInvalid){
				_allInvalid = false;
				drawList = _subjects;
				if(_measurements){
					_measurements.x = NaN;
					_measurements.y = NaN;
				}
			}else{
				drawList = _invalidSubjects;
				_invalidSubjects = new Dictionary();
				// TODO: in this case a bug could arise where the old measurements of an invalid subject are
				// bigger than the new ones, but are not removed from the total measurements
			}
			for(var i:* in drawList){
				drawSubject(i as ILayoutSubject);
			}
			if(!isNaN(_measurements.x) ||
				!isNaN(_measurements.y)){
				dispatchMeasurementChange();
			}
		}
		protected function drawSubject(subject:ILayoutSubject) : void{
			getMarginAffectedArea(_displayPosition,subject.layoutInfo,_marginAffectedArea,_marginRect);
			subject.setDisplayPosition(_marginAffectedArea.x,_marginAffectedArea.y,_marginAffectedArea.width,_marginAffectedArea.height);
			
			var subMeas:Point = subject.measurements;
			if(subMeas){
				addToMeas(subMeas.x+_marginRect.x+_marginRect.width,
							subMeas.y+_marginRect.y+_marginRect.height);
			}
		}
		protected function measure() : void{
			validate(true);
		}
		protected function addToMeas(width:Number, height:Number):void{
			var meas:Point = _measurements;
			if(isNaN(meas.x) || meas.x<width)meas.x = width;
			if(isNaN(meas.y) || meas.y<height)meas.y = height;
		}
		protected function dispatchMeasurementChange():void{
			_measureFlag.invalidate();
		}
		protected function onMeasInvalidate(validationFlag:ValidationFlag):void{
			if(_measurementsChanged)_measurementsChanged.perform(this, _measurements.x, _measurements.y);
		}
	}
}