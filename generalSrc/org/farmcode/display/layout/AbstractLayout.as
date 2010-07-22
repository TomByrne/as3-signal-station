package org.farmcode.display.layout
{
	
	import flash.display.DisplayObject;
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
		
		
		public function get readyForDraw():Boolean{
			return true;
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
		protected var _displayMeasurements:Rectangle = new Rectangle();
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
		public function get displayMeasurements():Rectangle{
			_measureFlag.validate();
			return _displayMeasurements;
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
		
		protected function onMeasumentsChange(from:ILayoutSubject, oldX:Number, oldY:Number, oldWidth:Number, oldHeight:Number): void{
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
				if(_displayMeasurements){
					_displayMeasurements.x = NaN;
					_displayMeasurements.y = NaN;
					_displayMeasurements.width = NaN;
					_displayMeasurements.height = NaN;
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
			if(!isNaN(_displayMeasurements.x) ||
				!isNaN(_displayMeasurements.y) ||
				!isNaN(_displayMeasurements.width) ||
				!isNaN(_displayMeasurements.height)){
				dispatchMeasurementChange();
			}
		}
		protected function drawSubject(subject:ILayoutSubject) : void{
			getMarginAffectedArea(_displayPosition,subject.layoutInfo,_marginAffectedArea,_marginRect);
			subject.setDisplayPosition(_marginAffectedArea.x,_marginAffectedArea.y,_marginAffectedArea.width,_marginAffectedArea.height);
			
			var subMeas:Rectangle = subject.displayMeasurements;
			if(subMeas){
				addToMeas(subMeas.x-_marginRect.x,
					subMeas.y-_marginRect.y,
					subMeas.width+_marginRect.x+_marginRect.width,
					subMeas.height+_marginRect.y+_marginRect.height);
			}
		}
		protected function measure() : void{
			validate(true);
		}
		protected function addToMeas(x:Number, y:Number, width:Number, height:Number):void{
			var meas:Rectangle = _displayMeasurements;
			if(isNaN(meas.x) || meas.x>x)meas.x = x;
			if(isNaN(meas.y) || meas.y>y)meas.y = y;
			if(isNaN(meas.width) || meas.width<width)meas.width = width;
			if(isNaN(meas.height) || meas.height<height)meas.height = height;
		}
		protected function dispatchMeasurementChange():void{
			_measureFlag.invalidate();
		}
		protected function onMeasInvalidate(validationFlag:ValidationFlag):void{
			if(_measurementsChanged)_measurementsChanged.perform(this, _displayMeasurements.x, _displayMeasurements.y, _displayMeasurements.width, _displayMeasurements.height);
		}
	}
}