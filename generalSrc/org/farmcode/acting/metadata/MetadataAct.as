package org.farmcode.acting.metadata
{
	import org.farmcode.acting.acts.AsynchronousAct;
	
	public class MetadataAct extends AsynchronousAct
	{
		public var passExecution:Boolean;
		public var doAsynchronous:Boolean;
		
		public function MetadataAct(asyncHandler:Function=null, doAsynchronous:Boolean=true, passExecution:Boolean=false){
			super(asyncHandler);
			this.doAsynchronous = doAsynchronous;
			this.passExecution = passExecution;
		}
		override public function execute(endHandler:Function, params:Array):void{
			if(_asyncHandler!=null){
				var realParams:Array = [_lastExecution.parent?_lastExecution.parent.act:null];
				if(passExecution)realParams.push(_lastExecution);
				if(params.length)realParams = realParams.concat(params);
				if(doAsynchronous){
					realParams.unshift(endHandler!=null?endHandler:dummyEndHandler);
					_asyncHandler.apply(null,realParams);
				}else{
					_asyncHandler.apply(null,realParams);
					if(endHandler!=null){
						endHandler();
					}
				}
			}else if(endHandler!=null){
				endHandler();
			}
		}
	}
}