package org.farmcode.sodalityLibrary.errors
{
	import org.farmcode.sodality.President;
	import org.farmcode.sodality.SodalityNamespace;
	import org.farmcode.sodality.advisors.DynamicAdvisor;
	import org.farmcode.sodality.advisors.IPresidentAwareAdvisor;
	import org.farmcode.sodality.events.PresidentEvent;
	import org.farmcode.sodalityLibrary.errors.advice.DetailedErrorAdvice;
	import org.farmcode.sodalityLibrary.errors.adviceTypes.IErrorAdvice;
	
	use namespace SodalityNamespace;

	/**
	 * The ErrorAdvisor will throw any errors that don't get caught be any other advisors (via the IErrorAdvice interface).
	 */
	public class ErrorAdvisor extends DynamicAdvisor implements IPresidentAwareAdvisor
	{
		public function set president(president: President): void{
			if(_president != president){
				if(_president){
					_president.removeEventListener(PresidentEvent.ADVICE_EXECUTE, onAdviceExecute);
				}
				this._president = president;
				if(_president){
					_president.addEventListener(PresidentEvent.ADVICE_EXECUTE, onAdviceExecute);
					_president.dispatchEvents = true;
				}
			}
		}
		public function get president(): President{
			return this._president;
		}
		
		private var _president:President;
		
		public function ErrorAdvisor(){
			super();
		}
		protected function onAdviceExecute(e:PresidentEvent):void{
			var cast:IErrorAdvice = e.advice as IErrorAdvice;
			if(cast && !e.adviceExecutionNode.executeAfter.length && !e.adviceExecutionNode.executeBefore.length){
				var detailed:DetailedErrorAdvice = (cast as DetailedErrorAdvice);
				var details:String;
				if(detailed && detailed.errorDetails && detailed.errorDetails.message){
					details = ": "+detailed.errorDetails.message;
				}else{
					details = "";
				}
				throw new Error(cast.errorType+details);
			}
		}
	}
}