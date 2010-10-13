package org.farmcode.display.layout
{
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.acting.acts.Act;
	import org.farmcode.binding.PropertyWatcher;
	import org.farmcode.binding.Watchable;
	import org.farmcode.display.core.IView;
	import org.farmcode.display.layout.core.ILayoutInfo;
	import org.farmcode.display.validation.FrameValidationFlag;
	import org.farmcode.display.validation.ValidationFlag;
	
	public class AbstractLayout extends LayoutSubject implements ILayout
	{
		
		private const scopeView_name:String = "scopeView";
		
		public function get scopeView():IView{return _get(scopeView_name);}
		public function set scopeView(value:IView):void{_set(scopeView_name,value);}
		public function get scopeViewChanged():IAct{return _getAct(scopeView_name);}
		
		
		protected var _subjects:Dictionary = new Dictionary();
		
		
		public function AbstractLayout(scopeView:IView){
			super([scopeView_name]);
			new PropertyWatcher(scopeView_name,setScopeView,null,null,this);
			
			this.scopeView = scopeView;
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
			setPosition(x, y);
			setSize(width, height);
		}
		
		protected function onSubjectMeasChanged(from:ILayoutSubject, oldWidth:Number, oldHeight:Number): void{
			// override me
		}
		/*protected function doMeasurementsChanged(): void{
			_measureFlag.invalidate();
			if(_measurementsChanged)_measurementsChanged.perform(this, _measurements.x, _measurements.y);
		}*/
		override protected function measure() : void{
			if(drawToMeasure()){
				validate(true);
			}
		}
	}
}