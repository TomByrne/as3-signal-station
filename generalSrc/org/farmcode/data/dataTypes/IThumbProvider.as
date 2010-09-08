package org.farmcode.data.dataTypes
{
	import org.farmcode.acting.actTypes.IAct;
	import org.farmcode.media.IMediaSource;

	public interface IThumbProvider
	{
		/**
		 * handler(from:IThumbProvider)
		 */
		function get thumbChanged():IAct;
		function get thumb():IMediaSource;
	}
}