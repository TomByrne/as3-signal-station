package org.tbyrne.external
{
	import flash.events.AsyncErrorEvent;
	import flash.net.NetConnection;
	import flash.utils.Dictionary;

	public class RemotingNetConnection extends NetConnection
	{
		public static const CREDENTIALS_HEADER_PARAM: String = "Credentials";
		
		private var originalURL: String;
		private var urlSuffix: String;
		private var addedHeaders:Dictionary = new Dictionary();

		public function RemotingNetConnection(gatewayURL: String)
		{
			this.originalURL = gatewayURL;
			if (gatewayURL)
			{
				super.connect(gatewayURL);
			}
			
			this.addEventListener(AsyncErrorEvent.ASYNC_ERROR, this.handleAsyncErrorEvent);
		}

		public function setCredentials(userId:String, password:String):void
		{
			var data: Object = new Object();
			data.userid = userId;
			data.password = password;
			this.addHeader(RemotingNetConnection.CREDENTIALS_HEADER_PARAM, false, data);
		}
		
		public function clearCredentials(): void
		{
			this.addHeader(RemotingNetConnection.CREDENTIALS_HEADER_PARAM);
		}

		public function AppendToGatewayUrl(urlSuffix:String):void
		{
			this.urlSuffix = urlSuffix;
			var url: String = this.originalURL + this.urlSuffix;
			super.connect(url);
		}

		private function ReplaceGatewayUrl(newURL: String):void
		{
			super.connect(newURL);
		}

		public function RequestPersistentHeader(info: Object): void
		{
			this.addHeader(info.name, info.mustUnderstand, info.data);
		}
		
		/**
		 * There is an informal interface expected to be adhered to by NetConnection
		 * for remoting calls. If there is a function missing, this will be fired. We should implement
		 * any callback function that is required (see error details)
		 */
		private function handleAsyncErrorEvent(event: AsyncErrorEvent): void
		{
			Log.log(Log.DEV_INFO, "Remoting ASyncError - " + event.error);
			this.dispatchEvent(event);
		}
		
		override public function addHeader(operation:String, mustUnderstand:Boolean=false, param:Object=null) : void{
			if(param!=null){
				addedHeaders[operation] = true;
				super.addHeader(operation, mustUnderstand, param);
			}else if(addedHeaders[operation]){
				super.addHeader(operation, mustUnderstand, param);
			}
		}
	}
}