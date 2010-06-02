package org.farmcode.sodalityLibrary.external.remoting.advice
{
	import org.farmcode.external.RemotingNetConnection;
	import org.farmcode.sodality.advice.Advice;
	import org.farmcode.sodalityLibrary.data.IDataProviderAdvice;
	import org.farmcode.sodalityLibrary.external.remoting.RemotingAdviceResultType;
	import org.farmcode.sodalityLibrary.external.remoting.adviceTypes.IRemotingAdvice;

	public class RemotingAdvice extends Advice implements IDataProviderAdvice, IRemotingAdvice
	{	
		[Property(toString="true",clonable="true")]
		public function get userId():String{
			return _userId;
		}
		public function set userId(value:String):void{
			if(_userId!=value){
				_userId = value;
			}
		}
		
		[Property(toString="true",clonable="true")]
		public function get password():String{
			return _password;
		}
		public function set password(value:String):void{
			if(_password!=value){
				_password = value;
			}
		}
		
		[Property(toString="true",clonable="true")]
		public function get timeout():Number{
			return _timeout;
		}
		public function set timeout(value:Number):void{
			_timeout = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get netConnection():RemotingNetConnection{
			return _netConnection;
		}
		public function set netConnection(value:RemotingNetConnection):void{
			_netConnection = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get useCredentials():Boolean{
			return _useCredentials;
		}
		public function set useCredentials(value:Boolean):void{
			_useCredentials = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get method():String{
			return _method;
		}
		public function set method(value:String):void{
			_method = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get parameters():Array{
			return _parameters;
		}
		public function set parameters(value:Array):void{
			_parameters = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get resultType():String{
			return _resultType;
		}
		public function set resultType(value:String):void{
			_resultType = value;
		}
		
		[Property(toString="true",clonable="true")]
		public function get result():*{
			return _result;
		}
		public function set result(value:*):void{
			_result = value;
		}
		public function get success():Boolean{
			return resultType==RemotingAdviceResultType.SUCCESS;
		}
		
		private var _result:*;
		private var _resultType:String;
		private var _parameters:Array;
		private var _method:String;
		private var _useCredentials:Boolean;
		private var _netConnection:RemotingNetConnection;
		private var _timeout:Number;
		private var _password:String;
		private var _userId:String;
		
		/**
		 * Creates a new remoting call
		 * 
		 * @param	method			The remote method this call represents
		 * @param	parameters		Paramters for the remote method
		 * @param	useCredentials	Whether this call will send credentials
		 * @param	userId			The user id to send as credentials
		 * @param	password		The password to send as credentials
		 */
		public function RemotingAdvice(method:String=null, parameters:Array=null, 
			useCredentials: Boolean = false, userId: String = null, 
			password: String = null){
				this.method = method;
				this.parameters = parameters;
				this.useCredentials = useCredentials;
				this.userId = userId;
				this.password = password;
		}
	}
}