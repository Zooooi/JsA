/*断点续传程序*/

package JsA.loader
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import JsC.events.JEvent;
	
	[Event(name="LOADER_PROGRESS", type="JsC.events.JEvent")]
	[Event(name="LOADER_OPEN", type="JsC.events.JEvent")]
	[Event(name="LOADER_COMPLETE", type="JsC.events.JEvent")]
	
	public class LoadFile extends EventDispatcher
	{
		private var file:File
		private var urlLoader:URLLoader
		private var fileRequest:URLRequest
		private var sType:String;
		private var request:URLRequest 
		
		private var contentLength:int
		private var range:int = 100000;
		
		public function LoadFile()
		{
			
		}
		public function start2(request:String, fileName:String):void 
		{   
			fileRequest = new URLRequest(request);
			start(fileRequest,fileName);
		}
		public function start(request:URLRequest, fileName:String):void 
		{   
			trace(this);
			fileRequest = request;
			sType = "";
			file = new File(fileName)
			startLoad() 
		}
		
		private function startLoad():void
		{
			urlLoader = new URLLoader();   
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY; 
			urlLoader.addEventListener(Event.OPEN,onOpen);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onIoEror); 
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurity);  
			urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgressEvent);
			urlLoader.load(fileRequest); 
			dispatchEvent(new JEvent(JEvent.LOADER_START));
		}
		
		
		protected function onProgressEvent(event:ProgressEvent):void
		{
			contentLength = event.bytesTotal
			trace("contentLength:",contentLength)
			
			sType = event.type
			urlLoader.close()
			onLoading()
			
			
		}
		protected function onLoading():void
		{
			var startPoint:int
			var bytesTotal:int
			var endPoint:int
			var fileStr:FileStream = new FileStream();
			if(file.exists) {//如果文件是存在的，就说明下载过，需要计算从哪个点开始下载
				fileStr.open(file, FileMode.READ);
				startPoint = fileStr.bytesAvailable;//计算从哪个点开始下载
				fileStr.close();//关闭文件流
			}
			if(startPoint+range>contentLength) {//确定下载的区间范围，比如0-10000
				endPoint = contentLength;
			} else {
				endPoint = startPoint+range;
			}
			//trace("onLoading",file.url,startPoint,endPoint);
			var request:URLRequest = fileRequest;
			var header:URLRequestHeader = new URLRequestHeader("Range", "bytes="+startPoint+"-"+endPoint);//注意这里很关键，我们在请求的Header里包含对Range的描述，这样服务器会返回文件的某个部分
			request.requestHeaders.push(header);//将头信息添加到请求里
			
			urlLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;//设置数据类型为字节
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onIoEror); 
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurity); 
			urlLoader.addEventListener(Event.COMPLETE ,function(e:Event):void {
				trace(header.value);
				var currentData:ByteArray = urlLoader.data;//得到下载的数据
				fileStr = new FileStream();
				fileStr.open(file, FileMode.UPDATE);
				fileStr.position = fileStr.bytesAvailable;//将指针指向文件尾
				fileStr.writeBytes(currentData, 0, currentData.length);//在文件中写入新下载的数据
				fileStr.close();//关闭文件流
				if(endPoint<contentLength) {
					var _event:JEvent = new JEvent(JEvent.LOADER_PROGRESS)
					_event._x = startPoint
					_event._y = contentLength
					dispatchEvent(_event)
					onLoading();//如果下载没有完成，则执行下一个断点下载，直到下载完毕整个文件
				}else{
					dispatchEvent(new JEvent(JEvent.LOADER_COMPLETE))
				}
			});
			urlLoader.load(request);//发起请求
			
		}
		protected function onOpen(event:Event):void
		{
			sType = event.type;
			dispatchEvent(new JEvent(JEvent.LOADER_OPEN));
		}
		protected function onSecurity(event:SecurityErrorEvent):void
		{
			onErrorAction(event)
		}
		protected function onIoEror(event:IOErrorEvent):void
		{
			onErrorAction(event)
		}
		private function onErrorAction(event:Object):void
		{
			trace(event.type,event); 
			var _urlLoader:URLLoader = URLLoader(event.currentTarget)
			_urlLoader.removeEventListener(event.type,arguments.callee);
			dispatchEvent(new JEvent(JEvent.LOADER_ERROR));
			setTimeout(function():void{startLoad()},5000)
		}
		
		public function stop():void
		{
			if (sType !="" && sType != Event.COMPLETE) 
			{
				sType = ""
				urlLoader.close();
			}
		}
	}
}