package JsA.loader
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.OutputProgressEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import JsC.events.JEvent;
	import JsC.mdel.SystemOS;
	
	import deng.fzip.FZip;
	import deng.fzip.FZipErrorEvent;
	import deng.fzip.FZipEvent;
	import deng.fzip.FZipFile;
	
	
	[Event(name="PROGRESS", type="JsC.events.JEvent")]
	[Event(name="COMPLETE", type="JsC.events.JEvent")]
	[Event(name="ALLCOMPLETE", type="JsC.events.JEvent")]
	
	
	public class ExtraZip extends EventDispatcher
	{
		private var zip:FZip
		private var nCount:uint;
		private var nLength:uint;
		private var zipPath:String
		private var zipFile:String
		private var bPass:Boolean
		
		private var fs:FileStream = new FileStream
		public function ExtraZip()
		{
			zip = new FZip
			zip.addEventListener(Event.OPEN,onOpen)
			zip.addEventListener(FZipErrorEvent.PARSE_ERROR,onZipError)
			zip.addEventListener(IOErrorEvent.IO_ERROR,onIoError)
		}
		
		
		
		public function start(_zipfile:String,_path:String):void
		{
			zip.addEventListener(FZipEvent.FILE_LOADED,onZipLoad_FileLoaded)
			zip.addEventListener(Event.COMPLETE,onZipLoad_Complete)
			loader_action(_zipfile,_path)
		}
		
		public function startByStep(_zipfile:String,_path:String):void
		{
			zip.addEventListener(Event.COMPLETE,onZipLoad_Complete2)
			loader_action(_zipfile,_path)
		}
		
		private function loader_action(_zipfile:String,_path:String):void
		{
			zipPath = _path;
			zipFile = _zipfile
			if (SystemOS.isAndroid()){
				loader_android()
			}else{
				loader_normal()
			}
		}
		
		private function loader_android():void
		{
			fs = new FileStream();
			var _file:File = new File(zipFile)
			fs.open(_file,FileMode.READ)
			var bytes:ByteArray = new ByteArray
			fs.readBytes(bytes);
			fs.close();
			zip.loadBytes(bytes);
		}
		
		private function loader_normal():void
		{
			zip.addEventListener(ProgressEvent.PROGRESS,onProgress)
			zip.load(new URLRequest(zipFile));
		}
		
		protected function onZipLoad_FileLoaded(event:FZipEvent):void
		{
			nLength = zip.getFileCount()
			var _one:FZipFile = event.file
			extraFile(_one)
		}
		
		private function onZipLoad_Complete(event:Event):void
		{
			dispatchEvent(new JEvent(JEvent.ALLCOMPLETE));
			zip.close()
		}
		
		protected function onProgress(event:ProgressEvent):void
		{
			var _event:JEvent = new JEvent(JEvent.PROGRESS)
			_event._x = event.bytesLoaded
			_event._y = event.bytesTotal
			dispatchEvent(_event);
		}
		
		protected function onZipLoad_Complete2(event:Event):void
		{
			trace(this,event.type)
			nCount = 0;
			nLength = zip.getFileCount()
			bPass = false
			unzip()
		}
		
		
		private function unzip():void
		{
			if (bPass)return
			fs.close()
			if(nCount<nLength)
			{
				var _one:FZipFile = zip.getFileAt(nCount);
				if (_one.filename.indexOf("/.")<0 && _one.filename.lastIndexOf("/")!=_one.filename.length-1)
				{
					var _file:File = new File(zipPath + _one.filename)
					var bytes:ByteArray = _one.content as ByteArray;    
					fs = new FileStream;
					fs.addEventListener(Event.CLOSE,function(event:Event):void
					{
						if (!bPass)
						{
							setTimeout(unzip,5)
						}
						
					})
					/*fs.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS,function(event:OutputProgressEvent):void
					{
						if (event.bytesPending == 0)
						{
							
						}
					});*/
					fs.openAsync(_file, FileMode.WRITE);    
					fs.position = 0;    
					fs.writeBytes(bytes, 0, bytes.length);
					fs.close()
				}else{
					setTimeout(unzip,5)
				}
				dispatch_extra()
			}else{
				dispatchEvent(new JEvent(JEvent.ALLCOMPLETE));
				zip.close()
			}
		}
		
		 private function dispatch_extra():void
		{
			 var _event:JEvent = new JEvent(JEvent.COMPLETE)
			 _event._x = nCount + 1
			 _event._y = nLength
			 dispatchEvent(_event)
			 nCount++
		}
		
		private function extraFile(_one:FZipFile):void
		{
			trace(_one.filename)
			if (_one.filename.indexOf("/.")<0 && _one.filename.lastIndexOf("/")!=_one.filename.length-1)
			{
				var _file:File = new File(zipPath + _one.filename)
				var bytes:ByteArray = _one.content as ByteArray;    
				fs = new FileStream; 
				fs.openAsync(_file, FileMode.WRITE);    
				fs.position = 0;    
				fs.writeBytes(bytes, 0, bytes.length);
				fs.close()
			}
			dispatch_extra()
		}
	
		
		
		public function close():void
		{
			bPass = true
			fs.close();
			zip.close()
		}
		
		
		protected function onOpen(event:Event):void
		{
			trace(this,event.type,event)
		}		
		
		
		protected function onIoError(event:IOErrorEvent):void
		{
			trace(this,event.type,event)
		}
		
		protected function onZipError(event:FZipErrorEvent):void
		{
			trace(this,event.type,event)
		}
		
		
	}
}