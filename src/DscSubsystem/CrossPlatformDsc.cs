// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.ObjectModel;
using System.Collections.Generic;
using System.Management.Automation;
using System.Management.Automation.Internal;
using System.Management.Automation.Language;

namespace System.Management.Automation.Subsystem
{
    /// <summary>
    /// Interface for implementing a cross platform desired state configuration component.
    /// </summary>
    public class CrossPlatformDsc : ICrossPlatformDsc, IModuleAssemblyInitializer
    {
        /// <summary>
        /// Gets the unique identifier for a subsystem implementation.
        /// </summary>
        public Guid Id { get {return Guid.NewGuid();} }

        /// <summary>
        /// Gets the name of a subsystem implementation.
        /// </summary>
        public string Name { get {return "Cross platform desired state configuration";} }

        /// <summary>
        /// Gets the description of a subsystem implementation.
        /// </summary>
        public string Description { get {return "Cross platform desired state configuration";} }

        /// <summary>
        /// Gets a dictionary that contains the functions to be defined at the global scope of a PowerShell session.
        /// Key: function name; Value: function script.
        /// </summary>
        Dictionary<string, string>? ISubsystem.FunctionsToDefine => null;

        /// <summary>
        /// Test.
        /// </summary>
        public void LoadDefaultCimKeywords(Collection<Exception> errors)
        {
            Microsoft.PowerShell.DesiredStateConfiguration.Internal.CrossPlatform.DscClassCache.LoadDefaultCimKeywords(errors);
        }

        /// <summary>
        /// Default summary.
        /// </summary>
        public void ClearCache()
        {
            Microsoft.PowerShell.DesiredStateConfiguration.Internal.CrossPlatform.DscClassCache.ClearCache();
        }

        /// <summary>
        /// Default summary.
        /// </summary>
        public bool NewApiIsUsed
        {
            get
            {
                return Microsoft.PowerShell.DesiredStateConfiguration.Internal.CrossPlatform.DscClassCache.NewApiIsUsed;
            }
        }

        /// <summary>
        /// Default summary.
        /// </summary>
        public string GetDSCResourceUsageString(DynamicKeyword keyword)
        {
            return Microsoft.PowerShell.DesiredStateConfiguration.Internal.CrossPlatform.DscClassCache.GetDSCResourceUsageString(keyword);
        }

        /// <summary>
        /// Test.
        /// </summary>
        public void RegisterSubsystemIfNotAlready()
        {
            if (SubsystemManager.GetSubsystem<ICrossPlatformDsc>() == null)
            {
                SubsystemManager.RegisterSubsystem(SubsystemKind.CrossPlatformDsc, this);
            }
        }

        public void OnImport()
        {
            RegisterSubsystemIfNotAlready();
        }
    }
}
