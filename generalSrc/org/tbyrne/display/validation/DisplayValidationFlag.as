package org.tbyrne.display.validation
{
	import flash.display.DisplayObject;
	import flash.events.ErrorEvent;
	
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.acting.acts.Act;


	
	public class DisplayValidationFlag extends FrameValidationFlag
	{
		public static const WITH_DISPLAY_CHECKER:Function = function(from:DisplayValidationFlag):Boolean{return from.display!=null};
		
		
		public function get display():DisplayObject{
			return _display;
		}
		public function set display(value:DisplayObject):void{
			if(_display!=value){
				if(_added){
					// remove before changing asset to allow manager to lookup by asset
					setAdded(false);
				}
				
				_display = value;
				
				if(_display){
					setAdded(true);
				}
			}
		}
		private var _display:DisplayObject;
		
		public function DisplayValidationFlag(display:DisplayObject, validator:Function, valid:Boolean, parameters:Array=null, readyChecker:Function=null){
			if(readyChecker==null)readyChecker = WITH_DISPLAY_CHECKER;
			super(validator, valid, parameters, readyChecker);
			this.display = display;
			_manager = FrameValidationManager.instance;
			checkAdded();
		}
		
		private function checkAdded():void{
			if(_display || readyForExecution){
				setAdded(true);
			}else{
				setAdded(false);
			}
		}
		override public function release():void{
			super.release();
			this.display = null;
		}
		
		override public function isDescendant(child:IFrameValidationFlag):Boolean{
			CONFIG::debug{
				if(!_display){
					Log.error("isDescendant shouldn't be called until a display is set.");
				}
			}
			
			var displayFlag:DisplayValidationFlag = (child as DisplayValidationFlag);
			if(displayFlag && displayFlag.display){
				var subject:DisplayObject = displayFlag.display.parent;
				while(subject && subject!=_display){
					subject = subject.parent;
				}
				return (subject!=null);
			}else{
				return false;
			}
		}
		override public function get hierarchyKey():*{
			CONFIG::debug{
				if(!_display){
					Log.error("get hierarchyKey shouldn't be called until a display is set.");
				}
			}
			
			return _display;
		}
	}
}