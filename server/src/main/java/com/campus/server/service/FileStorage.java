package com.campus.server.service;

import com.campus.server.common.BizException;
import com.campus.server.config.AppProperties;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;

/**
 * 文件存储。V1 落本地磁盘，接口按对象存储的形状设计，将来换 OSS 只改这一个类。
 */
@Service
public class FileStorage {

    private final AppProperties props;

    public FileStorage(AppProperties props) {
        this.props = props;
    }

    public Path rootDir() {
        Path root = Paths.get(props.getUpload().getDir()).toAbsolutePath().normalize();
        try {
            Files.createDirectories(root);
        } catch (IOException ex) {
            throw new UncheckedIOException("无法创建上传目录 " + root, ex);
        }
        return root;
    }

    /** 写入对象，返回相对 objectKey。 */
    public void write(String objectKey, byte[] content) {
        Path target = resolve(objectKey);
        try {
            Files.createDirectories(target.getParent());
            Files.write(target, content, StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
        } catch (IOException ex) {
            throw new UncheckedIOException("写入文件失败: " + objectKey, ex);
        }
    }

    public byte[] read(String objectKey) {
        try {
            return Files.readAllBytes(resolve(objectKey));
        } catch (IOException ex) {
            throw new BizException(com.campus.server.common.ErrorCode.NOT_FOUND, "文件不存在");
        }
    }

    public boolean exists(String objectKey) {
        return Files.exists(resolve(objectKey));
    }

    /** 供前端直接访问的地址；本地部署就是 /api/v1/files/{objectKey}。 */
    public String publicUrl(String objectKey) {
        return "/api/v1/files/" + objectKey.replace('\\', '/');
    }

    /** 防止 ../../ 逃出上传目录。 */
    private Path resolve(String objectKey) {
        Path root = rootDir();
        Path target = root.resolve(objectKey).normalize();
        if (!target.startsWith(root)) {
            throw BizException.invalid("非法的文件路径");
        }
        return target;
    }
}
