package flash.net
{
	public class NetStreamStatus
	{
		public static const BUFFER_EMPTY:String					= "NetStream.Buffer.Empty";
		public static const BUFFER_FULL:String					= "NetStream.Buffer.Full";
		public static const BUFFER_FLUSH:String					= "NetStream.Buffer.Flush";
		
		public static const FAILED:String						= "NetStream.Failed";
		
		public static const PUBLISH_START:String				= "NetStream.Publish.Start";
		public static const PUBLISH_BADNAME:String				= "NetStream.Publish.BadName";
		public static const PUBLISH_IDLE:String					= "NetStream.Publish.Idle";
		
		public static const UNPUBLISH_SUCCESS:String			= "NetStream.Unpublish.Success";
		
		public static const PLAY_START:String					= "NetStream.Play.Start";
		public static const PLAY_STOP:String					= "NetStream.Play.Stop";
		public static const PLAY_FAILED:String					= "NetStream.Play.Failed";
		public static const PLAY_STREAMNOTFOUND:String			= "NetStream.Play.StreamNotFound";
		public static const PLAY_RESET:String					= "NetStream.Play.Reset";
		public static const PLAY_PUBLISHNOTIFY:String			= "NetStream.Play.PublishNotify";
		public static const PLAY_UNPUBLISHNOTIFY:String			= "NetStream.Play.UnpublishNotify";
		public static const PLAY_INSUFFICIENTBW:String			= "NetStream.Play.InsufficientBW";
		public static const PLAY_FILESSTRUCTUREINVALID:String	= "NetStream.Play.FileStructureInvalid";
		
		public static const PAUSE_NOTIFY:String					= "NetStream.Pause.Notify";
		
		public static const UNPAUSE_NOTIFY:String				= "NetStream.Unpause.Notify";
		
		public static const RECORD_START:String					= "NetStream.Record.Start";
		public static const RECORD_NOACCESS:String				= "NetStream.Record.NoAccess";
		public static const RECORD_STOP:String					= "NetStream.Record.Stop";
		public static const RECORD_FAILED:String				= "NetStream.Record.Failed";
		
		public static const SEEK_FAILED:String					= "NetStream.Seek.Failed";
		public static const SEEK_INVALID_TIME:String			= "NetStream.Seek.InvalidTime";
		public static const SEEK_NOTIFY:String					= "NetStream.Seek.Notify";

	}
}