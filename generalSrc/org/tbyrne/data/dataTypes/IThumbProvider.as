package org.tbyrne.data.dataTypes
{
	import org.tbyrne.acting.actTypes.IAct;
	import org.tbyrne.media.IMediaSource;

	public interface IThumbProvider
	{
		/**
		 * handler(from:IThumbProvider)
		 */
		function get thumbChanged():IAct;
		function get thumb():IMediaSource;
	}
}