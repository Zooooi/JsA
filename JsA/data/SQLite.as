package JsA.data
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.events.EventDispatcher;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;

	public class SQLite extends EventDispatcher
	{
		private static var _instance:SQLite;
		
		private var _firstConnect:Boolean;
		private var _conn:SQLConnection;
		private var _lastData:Array;
		
		// ********************************************** main
		public function SQLite(){
			_instance = this;
		}
		
		// ********************************************** public method
		public function open(file:File):void{
			_firstConnect = !file.exists;
			
			_conn = new SQLConnection();
			_conn.addEventListener(SQLEvent.OPEN, openHandler);
			_conn.open(file);
		}
		public function execute(sql:String):void{
			var statement:SQLStatement = new SQLStatement();
			statement.sqlConnection = _conn;
			statement.text = sql;
			statement.execute();
		}
		public function query(sql:String):void{
			var statement:SQLStatement = new SQLStatement();
			statement.sqlConnection = _conn;
			statement.text = sql;
			statement.addEventListener(SQLEvent.RESULT, resultHandler);
			statement.execute();
		}
		
		// ********************************************** getter
		public function get firstConnect():Boolean{
			return _firstConnect;
		}
		public function get lastData():Array{
			return _lastData;
		}
		
		// ********************************************** event - SQLConnection
		private function openHandler(event:SQLEvent):void{
			this.dispatchEvent(new SQLEvent(SQLEvent.OPEN));
		}

		// ********************************************** event - SQLStatement
		private function resultHandler(event:SQLEvent):void{
			var statement:SQLStatement = event.target as SQLStatement;
			_lastData = statement.getResult().data;
			this.dispatchEvent(event);
		}
		
		// ********************************************** public static method
		public static function getInstance():SQLite{
			return _instance;
		}
	}
}