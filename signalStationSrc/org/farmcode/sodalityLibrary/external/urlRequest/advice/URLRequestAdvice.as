package org.farmcode.sodalityLibrary.external.urlRequest.advice
{
	import flash.net.URLRequest;
	
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.external.urlRequest.adviceTypes.IURLRequestAdvice;
	
	public class URLRequestAdvice extends Advice implements IURLRequestAdvice
	{
		[Property(toString="true",clonable="true")]
		public function get urlRequest():URLRequest{
			return _urlRequest;
		}
		public function set urlRequest(value:URLRequest):void{
			_urlRequest = value;
		}
		[Property(toString="true",clonable="true")]
		public function get result():*{
			return _result;
		}
		public function set result(value:*):void{
			_result = value;
		}
		
		
		private var _result:*;
		private var _urlRequest:URLRequest;
		
		public function URLRequestAdvice(urlRequest:URLRequest=null){
			this.urlRequest = urlRequest;
		}
	}
}