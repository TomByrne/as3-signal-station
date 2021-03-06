package org.tbyrne.display.transition
{
	import org.tbyrne.display.assets.nativeTypes.IDisplayObject;
	
	/**
	 * The TransitionManager manages TransitionExecution objects, making sure that they're not trying to
	 * transition the same display. When the <code>execute()</code> method is called, any existing transitions
	 * which are operating on either the <code>start</code> or <code>finish</code> DisplayObjects are stopped.
	 * If the pre-existing transition in question was operating on the <code>start</code> parameter, then a
	 * snapshot is taken from the transition and used as the start display for the new transition.
	 * <br><br>
	 * Note that the TransitionExecution class can be used directly, the TransitionManager is purely
	 * intended to resolve conflicts between TransitionExecution instances.
	 * <br><br>
	 * To see details on the actual functionality of the transitions see the TransitionExecution class.
	 * 
	 * @see au.com.thefarmdigital.transitions.TransitionExecution
	 */
	public class TransitionManager
	{
		private static var _executions:Array = [];
		
		public static function execute(start:IDisplayObject, finish:IDisplayObject, transitions:Array, easing:Function=null):TransitionExecution{
			var trans:TransitionExecution = findExecution(finish);
			if(trans){
				start = trans.endEarly();
			}
			trans = findExecution(start);
			if(trans){
				start = trans.endEarly();
			}
			
			var ret:TransitionExecution = new TransitionExecution(transitions);
			ret.easing = easing;
			ret.startDisplay = start;
			ret.finishDisplay = finish;
			ret.transitionEnd.addHandler(onTransitionEnd);
			ret.execute();
			_executions.push(ret);
			return ret;
		}
		private static function onTransitionEnd(from:TransitionExecution):void{
			removeTransition(from);
		}
		private static function removeTransition(transition:TransitionExecution):void{
			var index:Number = _executions.indexOf(transition);
			if(index!=-1){
				_executions.splice(index,1);
				transition.transitionEnd.removeHandler(onTransitionEnd);
			}
		}
		private static function findExecution(visual:IDisplayObject):TransitionExecution{
			for each(var trans:TransitionExecution in _executions){
				if(trans.startDisplay==visual || trans.finishDisplay==visual){
					return trans;
				}
			}
			return null;
		}
	}
}