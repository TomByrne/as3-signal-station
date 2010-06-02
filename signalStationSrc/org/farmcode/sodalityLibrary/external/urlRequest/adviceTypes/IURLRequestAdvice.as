package org.farmcode.sodalityLibrary.external.urlRequest.adviceTypes
{
	import flash.net.URLRequest;
	
	import org.farmcode.sodality.advice.IAdvice;

	public interface IURLRequestAdvice extends IAdvice
	{
		function get urlRequest():URLRequest;
		function set result(value:*):void;
	}
}