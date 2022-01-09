//
//  AuxiliaryExecute+Spawn.swift
//  AuxiliaryExecute
//
//  Created by Cyandev on 2022/1/10.
//

import Foundation

#if swift(>=5.5)
@available(iOS 15.0, macOS 12.0.0, *)
public extension AuxiliaryExecute {
    
    static func spawnAsync(
        command: String,
        args: [String] = [],
        environment: [String: String] = [:],
        timeout: Double = 0,
        stdoutBlock: ((String) -> Void)? = nil,
        stderrBlock: ((String) -> Void)? = nil
    ) async -> ExecuteRecipe {
        return await withCheckedContinuation { cont in
            self.spawn(
                command: command,
                args: args,
                environment: environment,
                timeout: timeout,
                stdoutBlock: stdoutBlock,
                stderrBlock: stderrBlock
            ) { recipe in
                cont.resume(returning: recipe)
            }
        }
    }
    
}
#endif
