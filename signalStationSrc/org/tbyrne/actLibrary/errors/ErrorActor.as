package org.tbyrne.actLibrary.errors
{
	import org.tbyrne.actLibrary.core.UniversalActorHelper;
	import org.tbyrne.actLibrary.errors.actTypes.IDetailedErrorAct;
	import org.tbyrne.actLibrary.errors.actTypes.IErrorAct;
	import org.tbyrne.acting.ActingNamspace;
	import org.tbyrne.acting.universal.UniversalActExecution;
	
	use namespace ActingNamspace;

	/**
	 * The ErrorAdvisor will throw any errors that don't get caught be any other advisors (via the IErrorAct interface).
	 */
	public class ErrorActor extends UniversalActorHelper
	{
		public var errorDisplayPhases:Array = [ErrorPhases.ERROR_DISPLAY];
		
		public function ErrorActor(){
			super();
			metadataTarget = this;
		}
		[ActRule(ActClassRule)]
		[ActReaction(phases="<errorDisplayPhases>")]
		public function onActExecute(execution:UniversalActExecution, cause:IErrorAct):void{
			if(cause && execution.reactionCount==1){
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