package org.farmcode.acting.acts
{
	import org.farmcode.acting.actTypes.IAsyncUniversalAct;
	
	public class AsynchronousAct extends UniversalAct implements IAsyncUniversalAct
	{
		public function AsynchronousAct(asyncHandler:Function=null){
			super();
			this.asyncHandler = asyncHandler;
		}
		
		protected var _allowAutoExecute:Boolean = true;
		protected var _asyncHandler:Function;
		
		public function set allowAutoExecute(value:Boolean):void{
			_allowAutoExecute = value;
		}
		public function set asyncHandler(value:Function):void{
			_asyncHandler = value;
		}
		public function get asyncHandler():Function{
			return _asyncHandler;
		}
		public function execute(endHandler:Function, params:Array):void{
			if(_asyncHandler!=null){
				params.unshift(endHandler!=null?endHandler:dummyEndHandler);
				_asyncHandler.apply(null,params);
			}else if(endHandler!=null){
				endHandler();
			}
		}
		public function dummyEndHandler():void{
			// This is so everyone has something to hang on to.
		}
		override public function perform(... params) : void{
			super.perform.apply(null,params);
			if(_allowAutoExecute){
				execute(null, params);
			}
		}
	}
}