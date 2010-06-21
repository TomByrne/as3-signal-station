/*****************************************************
 *  
 *  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
 *  
 *****************************************************
 *  The contents of this file are subject to the Mozilla Public License
 *  Version 1.1 (the "License"); you may not use this file except in
 *  compliance with the License. You may obtain a copy of the License at
 *  http://www.mozilla.org/MPL/
 *   
 *  Software distributed under the License is distributed on an "AS IS"
 *  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *  License for the specific language governing rights and limitations
 *  under the License.
 *   
 *  
 *  The Initial Developer of the Original Code is Adobe Systems Incorporated.
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/
package flash.net
{
	/**
	 * The NetConnectionCodes class provides static constants for event types
	 * that a NetConnection dispatches as NetStatusEvents.
	 * @see flash.net.NetConnection
	 * @see flash.events.NetStatusEvent    
	 */ 
	public class NetConnectionCodes
	{
		/**
		 * "error"	Packet encoded in an unidentified format.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 4.0
		 */
		public static const CALL_BADVERSION:String = "NetConnection.Call.BadVersion";  		
		
		/**
		 * "error"	The NetConnection.call method was not able to invoke the server-side method or command.
		 * */
		public static const CALL_FAILED:String = "NetConnection.Call.Failed";	    	
		
		/**
		 * "error"	An Action Message Format (AMF) operation is prevented for security reasons. 
		 * Either the AMF URL is not in the same domain as the file containing the code calling the NetConnection.call() method, 
		 * or the AMF server does not have a policy file that trusts the domain of the the
		 * file containing the code calling the NetConnection.call() method.		
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 4.0
		 */
		public static const CALL_PROHIBITED:String = "NetConnection.Call.Prohibited"; 	
		
		/** 
		 * "status"	The connection was closed successfully.	
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 4.0
		 */
		public static const CONNECT_CLOSED:String = "NetConnection.Connect.Closed"; 	
		
		/**			
		 * "error"	The connection attempt failed.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 4.0
		 */ 
		public static const CONNECT_FAILED:String = "NetConnection.Connect.Failed"		
		
		/**
		 * "status"	The connection attempt succeeded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 4.0
		 */ 
		public static const CONNECT_SUCCESS:String = "NetConnection.Connect.Success";		
		
		/**
		 * "error"	The connection attempt did not have permission to access the application.			
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 4.0
		 */
		public static const CONNECT_REJECTED:String = "NetConnection.Connect.Rejected";		
		
		/**
		 * 	"error"	The specified application is shutting down.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 4.0
		 */ 
		public static const CONNECT_APPSHUTDOWN:String = "NetConnection.Connect.AppShutdown";
		
		/** 
		 * "error"	The application name specified during connect is invalid.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.0
		 *  @productversion OSMF 4.0
		 */
		public static const CONNECT_INVALIDAPP:String = "NetConnection.Connect.InvalidApp";	
	}
}
