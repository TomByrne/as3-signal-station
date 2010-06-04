package org.farmcode.actLibrary.errors
{
	import org.farmcode.actLibrary.core.UniversalActorHelper;
	import org.farmcode.actLibrary.errors.actTypes.IDetailedErrorAct;
	import org.farmcode.actLibrary.errors.actTypes.IErrorAct;
	import org.farmcode.acting.ActingNamspace;
	import org.farmcode.acting.universal.UniversalActExecution;
	import org.farmcode.sodality.SodalityNamespace;
	
	use namespace SodalityNamespace;
	use namespace ActingNamspace;

	/**
	 * The ErrorAdvisor will throw any errors that don't get caught be any other advisors (via the IErrorAdvice interface).
	 */
	public class ErrorActor extends UniversalActorHelper
	{
		public var errorDisplayPhases:Array = [ErrorPhases.ERROR_DISPLAY];
		
		public function ErrorActor(){
			super();
			metadataTarget = this;
		}
		[ActRule(ActClassRule)]
		[ActReaction(phases="{errorDisplayPhases}")]
		public function onAdviceExecute(execution:UniversalActExecution, cause:IErrorAct):void{
			if(cause && !execution.reactionCount){
				var detailed:IDetailedErrorAct = (cause as IDetailedErrorAct);
				var details:String;
				if(detailed && detailed.errorDetails && detailed.errorDetails.message){
					details = ": "+detailed.errorDetails.message;
				}else{
					details = "";
				}
				throw new Error(cause.errorType+details);
			}
			execution.continueExecution();
		}
	}
}